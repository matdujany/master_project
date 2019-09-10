function phi_dot = advanced_tegotae_rule(i_limb,phase,GRFs,inverse_map,frequency,sigma_advanced)
%ADVANCED_TEGOTAE_RULE Summary of this function goes here
%   Detailed explanation goes here

GRF_advanced_term = 0;
for i=1:length(GRFs)
    GRF_advanced_term = GRF_advanced_term + inverse_map(i_limb,i)*GRFs(i);
end
% phi_dot = 2 * pi * frequency + sigma_advanced * GRF_advanced_term * cos(phase);

phi_dot = 2 * pi * frequency + sigma_advanced * GRF_advanced_term * sign(cos(phase));

end

