function phi = compute_phi_complete_rule(GRF,GRP,timestamps_phi_update,phi_init,parms_locomotion)

n_timestamps = length(timestamps_phi_update);
n_limb = size(GRF,2);
phi = zeros(n_timestamps,n_limb);
phi(1,:) = phi_init;
for i=2:n_timestamps
    for i_limb = 1:n_limb
        earlier_phase = phi(i-1,i_limb);
        phi_dot = 2*pi*parms_locomotion.frequency + complete_rule(GRF(i,:),GRP(i,:),earlier_phase,i_limb,parms_locomotion);
        phi(i,i_limb)=earlier_phase+phi_dot*(timestamps_phi_update(i)-timestamps_phi_update(i-1))/1000;
        if phi(i,i_limb)>2*pi
            phi(i,i_limb) = phi(i,i_limb) -2*pi;
        end
    end
end

end

function feedback_term = complete_rule(GRF,GRP,phase,i_limb,parms_locomotion)
%GRF is 1xn_limbs
%GRP is 1xn_limbs
[u_hip,u_knee,v_hip,v_knee] = load_matrix_complete_rule();
feedback_term = parms_locomotion.sigma_hip*u_hip(i_limb,:)*GRF'*cos(phase) + ...
                parms_locomotion.sigma_knee*u_knee(i_limb,:)*GRF'*sin(phase) + ...
                - parms_locomotion.sigma_p_hip*v_hip(i_limb,:)*GRP'*cos(phase) + ...
                - parms_locomotion.sigma_p_knee*v_knee(i_limb,:)*GRP'*sin(phase);
end