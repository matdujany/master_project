function dir_oscillations_c1 = get_dir_oscillations_c1(desired_movement_speed_channel,weights_speed_fused,motors_class_c1)
%GET_DIR_OSCILLATIONS_C2 Summary of this function goes here
%   Detailed explanation goes here

n_limb=length(motors_class_c1);
dir_oscillations_c1 = ones(n_limb,1);
for i=1:n_limb
    if weights_speed_fused(desired_movement_speed_channel,motors_class_c1(i))<0
        dir_oscillations_c1(i,1)=-1;
    end 
end

end

