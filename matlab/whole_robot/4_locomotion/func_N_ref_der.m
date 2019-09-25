function N_der = func_N_ref_der(phi)
%FUNC_N_REF Summary of this function goes here
%   Detailed explanation goes here
%phi is s1xs2

a1 = [   -6.1943    0.2176    4.0852   -0.5303    2.7348   -3.6236];
limits = [0.6700    2.6500    3.4000    3.6000    5.1000    6.2832];

%phi is s1xs2
s1 = size(phi,1);
s2 = size(phi,2);

phi = mod(phi,2*pi);
N_der = zeros(s1,s2);
for k1=1:s1
    for k2=1:s2
        for i=1:length(limits)
            if phi(k1,k2)<limits(i)
                N_der(k1,k2) = a1(i);
                break;
            end
        end
    end
end

end