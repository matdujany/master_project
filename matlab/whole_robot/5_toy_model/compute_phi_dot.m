function phi_dot = compute_phi_dot(t,phi)

[omega,inverse_map] = get_Tegotae_parms();

GRF = compute_GRF_from_phis(phi);

phi_dot = omega + inverse_map*GRF .* cos(phi);

end

