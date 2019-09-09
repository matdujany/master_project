function phi_dot = compute_phi_dot(t,phi,omega,inverse_map,sigma,total_load,N_ref)

n_limb = size(inverse_map,1);
GRF = estimate_GRF_from_phi(phi,total_load,n_limb);

phi_dot = omega + sigma * inverse_map*(GRF - N_ref) .*sign(cos(phi));
% phi_dot = omega + sigma * inverse_map*GRF .* cos(phi);

end

