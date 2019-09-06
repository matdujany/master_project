function phi_dot = compute_phi_dot(t,phi,omega,inverse_map,sigma,total_load)

GRF = estimate_GRF_from_phi(phi,total_load);

phi_dot = omega + sigma * inverse_map*GRF .*sign(cos(phi));
% phi_dot = omega + sigma * inverse_map*GRF .* cos(phi);

end

