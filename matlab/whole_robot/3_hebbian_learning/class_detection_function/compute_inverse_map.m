function inv_map = compute_inverse_map(weights_lc_fused,motors_class_c2,parms)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

dir_oscillations_c2 = get_dir_oscillations_c2(weights_lc_fused,motors_class_c2);

%% z effect
n_limb=length(motors_class_c2);
z_effect_limb_to_lc = zeros(parms.n_lc,n_limb);
for i_limb=1:n_limb
    for i_lc = 1:parms.n_lc      
%          z_effect_limb_to_lc(i_lc,i_limb) = sum([-1 1].*dir_oscillations(i_limb,1:2) .* weights_lc_fused(3*i_lc,motors_classes(i_limb,1:2)));
        z_effect_limb_to_lc(i_lc,i_limb) = dir_oscillations_c2(i_limb) * weights_lc_fused(3*i_lc,motors_class_c2(i_limb));
    end
end
% h_directmap = plot_limb_to_lc_effect(z_effect_limb_to_lc,parms,['Direct map for movement in direction ' direction_list{desired_movement_speed_channel}]);
%  h_directmap = plot_limb_to_lc_effect(z_effect_limb_to_lc,parms);

%% inverse map for tegotae
z_effect_lc_to_limb = z_effect_limb_to_lc';
inv_map = z_effect_lc_to_limb/max(max(abs(z_effect_lc_to_limb))) ;



end

