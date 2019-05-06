function phi_dot = advanced_tegotae_rule(i_limb,phase,GRFs,parms_locomotion)
%ADVANCED_TEGOTAE_RULE Summary of this function goes here
%   Detailed explanation goes here
inverse_map = get_inverse_map();
GRF_advanced_term = 0;
for i=1:length(GRFs)
    GRF_advanced_term = GRF_advanced_term + inverse_map(i_limb,i)*GRFs(i);
end
phi_dot = 2 * pi * parms_locomotion.frequency - parms_locomotion.sigma_advanced * GRF_advanced_term * cos(phase);
end

