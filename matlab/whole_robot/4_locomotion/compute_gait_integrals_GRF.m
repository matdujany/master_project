function integrals_GRF_squared_stance = compute_gait_integrals_GRF(indexes_integral,GRF,phi,time)
%UNTITLED2 Computes integrals in stance only
%   Detailed explanation goes here

phi=mod(phi,2*pi);

n_limb = size(GRF,2);
integrals_GRF_squared_stance = zeros(n_limb,1);
for i=1:n_limb
    total_time_int = 0;
    for j=1:length(indexes_integral)
        if phi(i,indexes_integral(j))>pi
            delta_time = time(indexes_integral(j),i) - time(indexes_integral(j)-1,i);
            integrals_GRF_squared_stance(i,1) = integrals_GRF_squared_stance(i,1)+...
                GRF(indexes_integral(j),i)^2*delta_time;
            total_time_int = total_time_int + delta_time;
        end
    end
    integrals_GRF_squared_stance(i,1) = integrals_GRF_squared_stance(i,1)/total_time_int;
end

end

