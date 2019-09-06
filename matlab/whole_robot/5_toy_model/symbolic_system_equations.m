clear; close all; clc;

n_limb = 6;
[inverse_map,~] = get_inverse_map("X",110);

i_limb_ref = 1;

psi = sym('psi',[n_limb 1]);
psi_dot = sym('psi_dot',[n_limb 1]);

for k=1:n_limb
    psi_dot(k,1)=inverse_map(k,:)*sin(psi(k,1)-psi) + inverse_map(i_limb_ref,:)*sin(psi);
end