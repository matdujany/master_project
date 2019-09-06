%gait plot

clear; close all; clc;
addpath('../2_load_data_code');
addpath(genpath('../4_locomotion'));

%%
recordID = 34;
n_limb = 6;

[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
[inverse_map,sigma_advanced] = get_inverse_map(parms_locomotion.direction,parms_locomotion.id_map_used);

%%
phi = pos_phi_data.limb_phi;
time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
delta_phases = compute_delta_phases(phi);

[f_delta_phases,ax_delta_phases] = plot_delta_phases(time,delta_phases,recordID);

%%


duration_mean = 30; %in seconds
psi = mean(delta_phases(:,:,end-floor(duration_mean*10^3/parms.time_interval_twitch):end),3);

%%
psi_dot = zeros(n_limb,n_limb);
for k=1:n_limb
    for i=1:n_limb
        psi_dot(k,i) = sum(inverse_map(k,:).*sin(psi(k,:)))-sum(inverse_map(i,:).*sin(psi(i,:)));
    end
end

%%
psi_dot_time = zeros(n_limb,n_limb,size(phi,2));
for k=1:n_limb
    for i=1:n_limb
        for i_time = 1:size(phi,2)
            psi_dot_time(k,i,i_time) = sum(inverse_map(k,:).*sin(delta_phases(k,:,i_time)))-sum(inverse_map(i,:).*sin(delta_phases(i,:,i_time)));
        end
    end
end

[f_psi_dot,ax_psi_dot] = plot_delta_phases(time,psi_dot_time,recordID);

%%

for i_limb_ref_phase=1:6
    fun = @(psi)sys_eqn(psi,inverse_map,i_limb_ref_phase);
    sum(fun(psi(:,i_limb_ref_phase)).^2)
end
