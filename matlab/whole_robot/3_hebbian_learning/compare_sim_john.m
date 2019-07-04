clear;
close all; clc;

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');
addpath('class_detection_function');
addpath('analysis_plot_function');

%% Load data
recordID = 110;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);
weights_robotis = weights_robotis{5}(1:3*parms.n_lc,:);

%% load simulations
weights_simulation = dlmread('matrix_john/correlation_matrix_ramp.csv',' ');
h1 = hinton_john(weights_simulation,parms,1);
h1.Name = 'simulations John original';

% %%
% h2 = hinton_LC(weights_robotis,parms,1);
% h2.Name = 'Robotis';

%%
weights_sim=zeros(18,24);
for i=1:6
    weights_sim(1+3*(i-1),:)=weights_simulation(18+i,:);
    weights_sim(2+3*(i-1),:)=weights_simulation(12+i,:);
    weights_sim(3+3*(i-1),:)=weights_simulation(6+i,:);
end

weights_sim2=zeros(18,24);
motor_mapping = [2 3 4 5 6 8 7 1 11 12 9 10];
for i_m=1:12
    weights_sim2(:,[1:2]+2*(motor_mapping(i_m)-1))=weights_sim(:,[1:2]+2*(i_m-1));    
end

weights_sim3=zeros(18,24);
lc_mapping = [4 3 5 2 6 1];
for i_lc=1:6
    weights_sim3([1:3]+3*(lc_mapping(i_lc)-1),:)=weights_sim2([1:3]+3*(i_lc-1),:);    
end

h2 = hinton_LC(weights_sim3,parms,1);
h2.Name = 'simulations John';

weights_sim_reordered = weights_sim3;
%% weights selection
limb = get_good_limb(parms,recordID);
weights_fused = fuse_weights_sym_direction(weights_sim_reordered,parms);
h_lcz = plot_hinton_lc_limb_order(weights_fused,limb,parms);

%% limb assignment
% close all;
h_plot = check_limb_assignment(weights_fused,parms,recordID);

%% c2 detection
hardcode = true;
[motors_class_c2,likelihood_c2] = get_class_c2_maximize_deltas(limb,weights_fused);
if hardcode == true
    motors_class_c2 = [9 7 4 2 6 11];
end
dir_oscillations_c2 = get_dir_oscillations_c2(weights_fused,motors_class_c2);

%% z effect
n_limb=size(limb,1);
z_effect_limb_to_lc = zeros(parms.n_lc,n_limb);
for i_limb=1:n_limb
    for i_lc = 1:parms.n_lc
        z_effect_limb_to_lc(i_lc,i_limb) = dir_oscillations_c2(i_limb) * weights_fused(3*i_lc,motors_class_c2(i_limb));
    end
end
h_directmap = plot_limb_to_lc_effect(z_effect_limb_to_lc,parms);

%% inverse map for tegotae
z_effect_lc_to_limb = z_effect_limb_to_lc';
z_effect_lc_to_limb = z_effect_lc_to_limb/max(max(abs(z_effect_lc_to_limb))) ;
h_invmap = plot_lc_to_limb_inv_map(z_effect_lc_to_limb,parms);
h_invmap.Name = 'Inverse map with John data, my limb order'