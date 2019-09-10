function GRF = estimate_GRF_from_profile(phi,profile_recordID,profile_i_limb)

[profile_spline,~,~] = load_profile_N_phi(profile_recordID,profile_i_limb);
phi = mod(phi,2*pi);

GRF = ppval(profile_spline,phi);

end

