function [dir_oscillations,dir_oscillations_yaw] = get_dir_oscillations(desired_movement_speed_channel,motors_classes,weights_lc_fused,weights_speed_fused,weights_yaw_fused)
%GET_DIR_OSCILLATIONS Summary of this function goes here
%   Detailed explanation goes here

n_limb=size(motors_classes,1);
dir_oscillations = ones(n_limb,2);
dir_oscillations_yaw = ones(n_limb,1); %only class 1 for yaw.
for i=1:n_limb
    if weights_speed_fused(desired_movement_speed_channel,motors_classes(i,1))<0
        dir_oscillations(i,1)=-1;
    end 
    if weights_yaw_fused(1,motors_classes(i,1))<0
        dir_oscillations_yaw(i,1)=-1;
    end
end

dir_oscillations_c2 = get_dir_oscillations_c2(weights_lc_fused,motors_classes(:,2));
dir_oscillations(:,2) = dir_oscillations_c2;

end

