clear; 
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

export_plots = false;

%% Load data
recordID = 105;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);

weights = weights_robotis{parms.n_twitches};
weights_lc = weights(1:3*parms.n_lc,:);
weights_lc = 100 * weights_lc/max(max(abs(weights_lc))) ;
hinton_LC(weights_lc,parms,1);
hinton_LC_asymmetry(weights_lc,parms,1);

%%
weights_lc_fused = fuse_weights_sym_direction(weights_lc,parms);
hinton_LC_fused(weights_lc_fused,parms,1);

limb = get_good_limb(parms,recordID);
n_limb = size(limb,1);
weights_lc_fused_limb_order = zeros(size(weights_lc_fused));
for i=1:n_limb
    for j=1:2
        weights_lc_fused_limb_order(:,j+2*(i-1))=weights_lc_fused(:,limb(i,j));
    end
end

hinton_LC_limb(weights_lc_fused_limb_order,parms,limb,1);

%%
hinton_LC_limb_1_channel(3,weights_lc_fused_limb_order,parms,limb,1);
if export_plots
    export_fig(['figures_report/weights_lcz_limb_' num2str(recordID) '.pdf']);
end