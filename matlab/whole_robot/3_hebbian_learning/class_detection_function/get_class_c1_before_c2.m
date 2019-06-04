function [motors_classes,likelihood_class1,dir_oscillations,dir_oscillations_yaw] = get_class_c1_before_c2(desired_movement_speed_channel,limb,weights_speed_fused,weights_yaw_fused,weights_lc_fused)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

n_limb=size(limb,1);
motors_classes = zeros(n_limb,2); %class 1 are the movement effectors, class2 is the stance/swing effector
likelihood_class1 = zeros(n_limb,1);
dir_oscillations = ones(n_limb,2);
dir_oscillations_yaw = ones(n_limb,1); %only class 1 for yaw.
for i=1:n_limb
    limb_motor_list = limb(i,:);
    [values_c1, idx_c1 ] = maxk(abs(weights_speed_fused(desired_movement_speed_channel,limb_motor_list)),2);
    motors_classes(i,1) = limb_motor_list(idx_c1(1));
    likelihood_class1(i,1) = values_c1(1)/values_c1(2);
    limb_motor_list(idx_c1(1)) = [];
    [~, idx2 ] = max(abs(weights_lc_fused(3*i,limb_motor_list)));
    motors_classes(i,2) = limb_motor_list(idx2);
    
    if weights_speed_fused(desired_movement_speed_channel,motors_classes(i,1))<0
        dir_oscillations(i,1)=-1;
    end 
    if weights_yaw_fused(1,motors_classes(i,1))<0
        dir_oscillations_yaw(i,1)=-1;
    end
    if weights_lc_fused(3*i,motors_classes(i,2))>0
        dir_oscillations(i,2)=-1;
    end
end


end

