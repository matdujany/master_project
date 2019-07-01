clear; 
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');
addpath('class_detection_function');
addpath('analysis_plot_function');

%% Load data
recordID = 115;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);


if recordID < 128
    weights_speed_all = compute_weights_speed(data,lpdata,parms);
else
    for k=1:parms.n_twitches
        weights_speed_all{k} = weights_robotis{k}(end-5:end-3,:);
    end
end

%% rescaling and fusing
weights_speed = weights_speed_all{parms.n_twitches};
weights_speed = 100*weights_speed/max(max(abs(weights_speed)));
% hinton_speed(weights_speed,parms,1);

weights_speed_fused = fuse_weights_sym_direction(weights_speed,parms);
% hinton_speed_fused(weights_speed_fused,parms,1);

weights_yaw = weights_robotis{parms.n_twitches}(end,:);
weights_gyro = weights_robotis{parms.n_twitches}(end-2:end,:);
weights_yaw_rescaled = 100 * weights_yaw/max(max(abs(weights_gyro))) ;
weights_yaw_fused = fuse_weights_sym_direction(weights_yaw_rescaled,parms);

% weights_check = compute_weights_wrapper(data,lpdata,parms,0,0,0,0);
% weights_check_last = weights_check{parms.n_twitches};
weights_robotis_last = weights_robotis{parms.n_twitches};

weights_lc = weights_robotis_last(1:3*parms.n_lc,:);
weights_lc = 100*weights_lc/max(max(abs(weights_lc))) ;
% hinton_LC(weights_lc,parms,1);

weights_lc_fused = fuse_weights_sym_direction(weights_lc,parms);
% hinton_LC_fused(weights_lc_fused,parms,1);
weights_lcz_fused = weights_lc_fused(3*[1:size(weights_lc_fused,1)/3],:);


%% showing the initial data used
limb = get_good_limb(parms,recordID);
n_limb =size(limb,1);
% plot_hinton_speed_limb_order(weights_speed_fused,limb);

h_speed_yaw_limb = plot_hinton_speed_yaw_limb_order(weights_speed_fused,weights_yaw_fused,limb);
% h_speed_yaw_limb.Position = [126   178   970   600];
h_lcz = plot_hinton_lc_limb_order(weights_lc_fused,limb,parms);

%%
% close all;
% h_lcz = plot_hinton_lc_limb_order(weights_lc_fused,limb,parms);
% h_lcz = plot_hinton_lc_limb_order_renorm_column(weights_lc_fused,limb,parms)

% [h_lcz, weights_lcz_fused_limb_order_ratios] = plot_hinton_lc_limb_order_ratio_column(weights_lc_fused,limb,parms);

%%
motors_class_c2 = get_class_c2_maximize_deltas(limb,weights_lc_fused);
inv_map_max_deltas = get_inverse_map(weights_lc_fused,motors_class_c2,parms);
h_invmap_max_deltas = plot_lc_to_limb_inv_map(inv_map_max_deltas,parms);
h_invmap_max_deltas.Name = 'maximizing deltas';

%% 
desired_movement_speed_channel = 2; %1 for X, 2 for Y
direction_list = {'X','Y','Z'};
[motors_classes_c2_first,~,~,~] = get_class_c2_before_c1(desired_movement_speed_channel,limb,weights_speed_fused,weights_yaw_fused,weights_lc_fused);
inv_map_c2_first = get_inverse_map(weights_lc_fused,motors_classes_c2_first(:,2),parms);
h_invmap_c2_first = plot_lc_to_limb_inv_map(inv_map_c2_first,parms);
h_invmap_c2_first.Name = 'c2_first';

%%
desired_movement_speed_channel = 1; %1 for X, 2 for Y
direction_list = {'X','Y','Z'};
[motors_classes_c1_first_X,~,~,~] = get_class_c1_before_c2(desired_movement_speed_channel,limb,weights_speed_fused,weights_yaw_fused,weights_lc_fused);
inv_map_c1_first_X = get_inverse_map(weights_lc_fused,motors_classes_c1_first_X(:,2),parms);
h_invmap_c1_first_X = plot_lc_to_limb_inv_map(inv_map_c1_first_X,parms);
h_invmap_c1_first_X.Name = 'c1_first_X';


%%
desired_movement_speed_channel = 2; %1 for X, 2 for Y
direction_list = {'X','Y','Z'};
[motors_classes_c1_first_Y,~,~,~] = get_class_c1_before_c2(desired_movement_speed_channel,limb,weights_speed_fused,weights_yaw_fused,weights_lc_fused);
inv_map_c1_first_Y = get_inverse_map(weights_lc_fused,motors_classes_c1_first_Y(:,2),parms);
h_invmap_c1_first_Y = plot_lc_to_limb_inv_map(inv_map_c1_first_Y,parms);
h_invmap_c1_first_Y.Name = 'c1_first_Y';

