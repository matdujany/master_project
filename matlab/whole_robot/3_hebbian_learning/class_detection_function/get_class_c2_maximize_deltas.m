function [motors_class_c2,likelihood_c2] = get_class_c2_maximize_deltas(limb,weights_lc_fused)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

n_limb=size(limb,1);
motors_class_c2 = zeros(n_limb,1); %class2 is the stance/swing effector
likelihood_c2 = zeros(n_limb,1);
weights_lcz_fused = weights_lc_fused(3*[1:size(weights_lc_fused,1)/3],:);

for i=1:n_limb
    limb_motor_list = limb(i,:);
    score_motors = zeros(length(limb_motor_list),1);
    for i_motor=1:length(limb_motor_list)
        score_motors(i_motor) = abs(weights_lcz_fused(i,limb_motor_list(i_motor))) - max(abs(weights_lcz_fused([1:i-1 i+1:n_limb],limb_motor_list(i_motor))));
    end
    
    [values_c2, idx_c2 ] = maxk(score_motors,2);
    motors_class_c2(i,1) = limb_motor_list(idx_c2(1));
    likelihood_c2(i,1) = values_c2(1)/values_c2(2);
end



end

