clear; 
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 106;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);
hinton_IMU(weights_robotis{parms.n_twitches},parms,1);
hinton_LC_asymmetry(weights_robotis{parms.n_twitches},parms,1);

%% computing speed (integration of IMU data)
weights_speed_all = compute_weights_speed(data,lpdata,parms);
plot_weight_evolution_speed(weights_speed_all,parms);

weights_speed = weights_speed_all{parms.n_twitches};
weights_speed = 100 * weights_speed/max(max(abs(weights_speed))) ;
hinton_speed(weights_speed,parms,1);

weights_speed_fused = fuse_weights_sym_direction(weights_speed,parms);
% hinton_speed_fused(weights_speed_fused,parms,1);

%% reorganizing in limbs
[limb,~,~] = get_good_limb(parms,recordID);
n_limb = size(limb,1);
weights_speed_fused_limb_order = zeros(size(weights_speed_fused));
for i=1:n_limb
    for j=1:2
        weights_speed_fused_limb_order(:,j+2*(i-1))=weights_speed_fused(:,limb(i,j));
    end
end

h_speed_limb = hinton_speed_limb(weights_speed_fused_limb_order,limb,1);
h_speed_limb.Position = [929 327 899 437];
% export_fig 'figures_report/weights_speed_limb_88.pdf'

%%
weights_yaw = weights_robotis{parms.n_twitches}(end,:);
weights_gyro = weights_robotis{parms.n_twitches}(end-2:end,:);
weights_yaw_rescaled = 100 * weights_yaw/max(max(abs(weights_gyro))) ;
weights_yaw_fused = fuse_weights_sym_direction(weights_yaw_rescaled,parms);
n_limb = size(limb,1);
weights_yaw_fused_limb_order = zeros(size(weights_yaw_fused));
for i=1:n_limb
    for j=1:2
        weights_yaw_fused_limb_order(:,j+2*(i-1))=weights_yaw_fused(:,limb(i,j));
    end
end

h_speed_yaw_limb = hinton_speed_yaw_limb(weights_speed_fused_limb_order,weights_yaw_fused_limb_order,limb,1);
h_speed_yaw_limb.Position = [126   178   970   600];
% export_fig 'figures_report/weights_speed_yaw_limb_88.pdf'

%% finding the motors and directions to produce movement in X and Y direction
[motors_movement_effectors_X,dir_oscillations_X] = get_motors_and_signs(1, limb, weights_speed_fused);
[motors_movement_effectors_Y,dir_oscillations_Y] = get_motors_and_signs(2, limb, weights_speed_fused);


function [motors_movement_effectors,dir_oscillations] = get_motors_and_signs(desired_movement_speed_channel, limb, weights_speed_fused)
n_limb=size(limb,1);
motors_movement_effectors = zeros(n_limb,1);
dir_oscillations = ones(n_limb,1);
for i=1:n_limb
    limb_motor_list = limb(i,:);
    [~, idx ] = max(abs(weights_speed_fused(desired_movement_speed_channel,limb_motor_list)));
    motors_movement_effectors(i,1) = limb_motor_list(idx);
    if weights_speed_fused(desired_movement_speed_channel,limb_motor_list(idx))<0
        dir_oscillations(i,1)=-1;
    end        
end
end