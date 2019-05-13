function phi_dot = advanced_tegotae_rule(i_limb,phase,GRFs,parms_locomotion,sigma_advanced)
%ADVANCED_TEGOTAE_RULE Summary of this function goes here
%   Detailed explanation goes here
if nargin == 4
    [inverse_map,~] = get_inverse_map(parms_locomotion.direction,parms_locomotion.id_map_used);
else
    [inverse_map,sigma_advanced] = get_inverse_map(parms_locomotion.direction,parms_locomotion.id_map_used);
end
GRF_advanced_term = 0;
for i=1:length(GRFs)
    GRF_advanced_term = GRF_advanced_term + inverse_map(i_limb,i)*GRFs(i);
end
phi_dot = 2 * pi * parms_locomotion.frequency + sigma_advanced * GRF_advanced_term * cos(phase);
end

