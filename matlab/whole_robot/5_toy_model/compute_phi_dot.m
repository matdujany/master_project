function phi_dot = compute_phi_dot(t,phi,omega,inverse_map,sigma,total_load,N_ref,profilparms)

n_limb = size(inverse_map,1);
GRF = estimate_GRF_from_phi(phi,total_load,n_limb,profilparms);

% GRF_ref = estimate_GRF_from_profile(phi,profilparms.recordID,profilparms.i_limb);


phi_dot = omega + sigma * inverse_map*(GRF - N_ref) .*sign(cos(phi));
% phi_dot = omega + sigma * inverse_map*( GRF - GRF_ref) .*sign(cos(phi));

% phi_dot = omega + sigma * inverse_map*GRF .* cos(phi);

end
