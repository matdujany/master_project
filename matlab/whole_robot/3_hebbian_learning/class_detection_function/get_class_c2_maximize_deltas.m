function motors_class_c2 = get_class_c2_maximize_deltas(limb,weights_lcz_fused)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

n_limb=size(limb,1);
motors_class_c2 = zeros(n_limb,1); %class2 is the stance/swing effector


for i=1:n_limb
    limb_motor_list = limb(i,:);
    score_motors = zeros(length(limb_motor_list),1);
    for i_motor=1:length(limb_motor_list)
        score_motors(i_motor) = abs(weights_lcz_fused(i,limb_motor_list(i_motor))) - max(abs(weights_lcz_fused([1:i-1 i+1:n_limb],limb_motor_list(i_motor))));
    end
    
    [~, idx_c2 ] = max(score_motors);
    motors_class_c2(i,1) = limb_motor_list(idx_c2(1));
end



end

