function [simple_Tegotae, advanced_Tegotae, advanced_Tegotae_term_split] = compute_GRF_advanced_split(GRF,phi,inverse_map,sigma_advanced,GRF_ref)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

n_limb = size(inverse_map,1);

if nargin == 4
    GRF_ref = zeros(1,n_limb);
end

GRF = GRF - GRF_ref;

GRF_advanced_term = (inverse_map*GRF')';
simple_Tegotae =  -0.1*GRF.*cos(phi);
advanced_Tegotae = sigma_advanced * GRF_advanced_term .*cos(phi);

% for i=1:n_limb
%     simple_Tegotae(:,i) = -0.1*GRF(:,i).*cos(phi(:,i));
%     advanced_Tegotae(:,i) = sigma_advanced * GRF_advanced_term(:,i) .*cos(phi(:,i));
% %     advanced_Tegotae_without_cos(:,i) = sigma_advanced * GRF_advanced_term(:,i);
% end

advanced_Tegotae_term_split = zeros([size(GRF_advanced_term) n_limb]);
for i_limb_contrib=1:n_limb
    for i_limb_controlled=1:n_limb
        advanced_Tegotae_term_split(:,i_limb_controlled,i_limb_contrib) = ...
            sigma_advanced *inverse_map(i_limb_controlled,i_limb_contrib)*GRF(:,i_limb_contrib) .*cos(phi(:,i_limb_controlled));
    end
end

end

