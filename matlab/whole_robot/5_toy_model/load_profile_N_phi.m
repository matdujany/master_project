function [profile_spline,phi_grid,GRF_grid] = load_profile_N_phi(recordID,i_limb)
%LOAD_PROFILE_N_PHI Summary of this function goes here
%   Detailed explanation goes here
filename = ['profiles/record_' num2str(recordID) '_limb_' num2str(i_limb)];

load(filename,'profile_spline','phi_grid','GRF_grid');

end

