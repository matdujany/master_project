function [delta_phases] = compute_delta_phases(phi)
%COMPUTE_DELTA_PHASES Summary of this function goes here
%   Detailed explanation goes here
n_limb = size(phi,1);
delta_phases = zeros(n_limb,n_limb,size(phi,2));

for i_limb_ref=1:n_limb
    for i_limb = 1:n_limb
        delta_phases(i_limb,i_limb_ref,:) = unwrap(mod(phi(i_limb,:)-phi(i_limb_ref,:),2*pi));
    end
end

end

