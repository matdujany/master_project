function [integrals,integrals_squared,integrals_GRF_ref,integrals_GRF_ref_squared] = compute_gait_integrals(indexes_integral,GRF,GRF_ref,time)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

n_limb = size(GRF,2);

integrals = sum(GRF(indexes_integral,:).*diff(time([indexes_integral(1)-1 indexes_integral],1:n_limb)),1) ./ ...
    (time(indexes_integral(end),1:n_limb) - time(indexes_integral(1)-1,1:n_limb));

% integrals_squared = sum(GRF(indexes_integral,:).^2,1)/length(indexes_integral);

integrals_squared = sum(GRF(indexes_integral,:).^2.*diff(time([indexes_integral(1)-1 indexes_integral],1:n_limb)),1) ./ ...
    (time(indexes_integral(end),1:n_limb) - time(indexes_integral(1)-1,1:n_limb));

% integrals_GRF_ref = sum(abs(GRF(indexes_integral,:)-GRF_ref),1)/length(indexes_integral);
integrals_GRF_ref = sum(abs(GRF(indexes_integral,:)-GRF_ref).*diff(time([indexes_integral(1)-1 indexes_integral],1:n_limb)),1) ./ ...
    (time(indexes_integral(end),1:n_limb) - time(indexes_integral(1)-1,1:n_limb));

integrals_GRF_ref_squared = sum((GRF(indexes_integral,:)-GRF_ref).^2.*diff(time([indexes_integral(1)-1 indexes_integral],1:n_limb)),1) ./ ...
    (time(indexes_integral(end),1:n_limb) - time(indexes_integral(1)-1,1:n_limb));

end

