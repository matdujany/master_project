function [motors_classes,dir_oscillations,dir_oscillations_yaw,likelihood_c2] = get_class_c2_maximize_deltas_wrapper(desired_movement_speed_channel,limb,weights_speed_fused,weights_yaw_fused,weights_lc_fused)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

n_limb=size(limb,1);
[motors_class_c2,likelihood_c2] = get_class_c2_maximize_deltas(limb,weights_lc_fused);
motors_classes = zeros(n_limb,2);
for i=1:n_limb
    limb_motor_list = limb(i,:);
    limb_motor_list(limb_motor_list==motors_class_c2(i)) = [];
    [~, idx1 ] = max(abs(weights_speed_fused(desired_movement_speed_channel,limb_motor_list)));
    motors_classes(i,1) = limb_motor_list(idx1);
end
motors_classes(:,2) = motors_class_c2;

[dir_oscillations,dir_oscillations_yaw] = get_dir_oscillations(desired_movement_speed_channel,motors_classes,weights_lc_fused,weights_speed_fused,weights_yaw_fused);



end
