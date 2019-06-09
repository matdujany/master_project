
clear; 
close all; clc;

addpath('computing_functions');
addpath('hinton_plot_functions');

%% Load data
addpath('../2_load_data_code');
recordID = 86;
[data, lpdata, parms] =  load_data_processed(recordID);
parms = add_parms(parms);
% parms.n_useful_ch_IMU    = 6;
weights_robotis  = read_weights_robotis(recordID,parms);

%%
renorm_factor = max(max(abs(weights_robotis{parms.n_twitches})));
weights = 100*weights_robotis{parms.n_twitches}/renorm_factor;

hinton_LC(weights,parms,1);

%% fusing the weights over directions --> IS THIS THE PROPER WAY ?
weights_fused = fuse_weights_sym_direction(weights,parms);

%% z effect
[limb,~,~] = get_good_limb(parms,recordID);
n_limb = size(limb,1);

z_effect_limb_to_lc_hip = zeros(parms.n_lc,n_limb);
z_effect_limb_to_lc_knee = zeros(parms.n_lc,n_limb);

for i_limb=1:n_limb
    for i_lc = 1:parms.n_lc
        sign_correction_hip = 1;
        if weights_fused(3*i_limb,limb(i_limb,1))<0
            sign_correction_hip = -1;
        end
        z_effect_limb_to_lc_hip(i_lc,i_limb) = sign_correction_hip*weights_fused(3*i_lc,limb(i_limb,1));
        
        sign_correction_knee = 1;
        if weights_fused(3*i_limb,limb(i_limb,2))<0
            sign_correction_knee = -1;
        end        
        z_effect_limb_to_lc_knee(i_lc,i_limb) = sign_correction_knee*weights_fused(3*i_lc,limb(i_limb,2));
    end
end

plot_limb_to_lc_effect(z_effect_limb_to_lc_hip,parms,'Hip only');
plot_limb_to_lc_effect(z_effect_limb_to_lc_knee,parms,'Knee only');
