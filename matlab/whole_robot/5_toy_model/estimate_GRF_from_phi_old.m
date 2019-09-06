function GRF = estimate_GRF_from_phi(phi,total_load)

idx_legs_stance = find(mod(phi,2*pi) >= pi);
n_legs_stance = length(idx_legs_stance);

n_limb = length(phi);
GRF = zeros(n_limb,1);
for i=1:n_legs_stance
    GRF(idx_legs_stance(i),1) = total_load/n_legs_stance;
end


if n_legs_stance == 0
    GRF(:,1) = total_load/length(phi);
end

%checking right side
if sum(GRF(1:n_limb/2,1),2) == 0
    for i=1:n_legs_stance
        GRF(idx_legs_stance(i),1) = total_load/(n_legs_stance+n_limb/2);
    end
    GRF(1:n_limb/2,1) = total_load/(n_legs_stance+n_limb/2);
end

%checking left side
if sum(GRF(n_limb/2+1:end,1),2) == 0
    for i=1:n_legs_stance
        GRF(idx_legs_stance(i),1) = total_load/(n_legs_stance+n_limb/2);
    end
    GRF(n_limb/2+1:end,1) = total_load/(n_legs_stance+n_limb/2);
end


end

