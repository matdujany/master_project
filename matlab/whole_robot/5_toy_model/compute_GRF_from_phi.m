function GRF = compute_GRF_from_phi(phi)

total_mass = get_robot_parms();

idx_legs_stance = find(mod(phi,2*pi) >= pi);
n_legs_stance = length(idx_legs_stance);

GRF = zeros(length(phi));
for i=1:n_legs_stance
end



end

