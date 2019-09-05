function psi_dot = sys_eqn(psi,inverse_map,i_limb_ref)

n_limb = length(psi);
psi_dot = zeros(n_limb,1);
for k=1:n_limb
    psi_dot(k,1)=inverse_map(k,:)*sin(psi(k,1)-psi) + inverse_map(i_limb_ref,:)*sin(psi);
end

end