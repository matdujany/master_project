clear; 
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 86;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);


weights_speed_all = compute_weights_speed(data,lpdata,parms);
weights_speed = weights_speed_all{parms.n_twitches};
weights_speed = 100 * weights_speed/max(max(abs(weights_speed))) ;
hinton_speed(weights_speed,parms,1);

weights_speed_fused = fuse_weights_sym_direction(weights_speed,parms);
hinton_speed_fused(weights_speed_fused,parms,1);

%%
[limb,~,~] = get_good_limb(parms,recordID);
n_limb = size(limb,1);
weights_speed_fused_limb_order = zeros(size(weights_speed_fused));
for i=1:n_limb
    for j=1:2
        weights_speed_fused_limb_order(:,j+2*(i-1))=weights_speed_fused(:,limb(i,j));
    end
end

hinton_speed_limb(weights_speed_fused_limb_order,limb,1);

%%
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