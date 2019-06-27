function dir_oscillations_c2 = get_dir_oscillations_c2(weights_lc_fused,motors_class_c2)
%GET_DIR_OSCILLATIONS_C2 Summary of this function goes here
%   Detailed explanation goes here

n_limb=length(motors_class_c2);
dir_oscillations_c2 = ones(n_limb,1);
for i=1:n_limb
    if weights_lc_fused(3*i,motors_class_c2(i))>0
        dir_oscillations_c2(i,1)=-1;
    end
end

end

