function [motors_classes,likelihood_class2,dir_oscillations,dir_oscillations_yaw] = get_class_c2_before_c1(desired_movement_speed_channel,limb,weights_speed_fused,weights_yaw_fused,weights_lc_fused)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

n_limb=size(limb,1);
motors_classes = zeros(n_limb,2); %class 1 are the movement effectors, class2 is the stance/swing effector
likelihood_class2 = zeros(n_limb,1);

for i=1:n_limb
    limb_motor_list = limb(i,:);
    [values_c2, idx_c2 ] = maxk(abs(weights_lc_fused(3*i,limb_motor_list)),2);
    motors_classes(i,2) = limb_motor_list(idx_c2(1));
    likelihood_class2(i,1) = values_c2(1)/values_c2(2);
    limb_motor_list(idx_c2(1)) = [];

    
    [~, idx_c1 ] = max(abs(weights_speed_fused(desired_movement_speed_channel,limb_motor_list)));
    motors_classes(i,1) = limb_motor_list(idx_c1); 
end

[dir_oscillations,dir_oscillations_yaw] = get_dir_oscillations(desired_movement_speed_channel,motors_classes,weights_lc_fused,weights_speed_fused,weights_yaw_fused);



end

