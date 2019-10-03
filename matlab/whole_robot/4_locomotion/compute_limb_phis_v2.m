%to compute the limb phis using the complete rule.

clear; close all; clc;
addpath('../2_load_data_code');

recordID = 213;
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

n_limb = 6;
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion.direction,n_limb,recordID);
n_limb = size(limbs,1);
n_samples = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);

GRF = zeros(n_samples_GRF,n_limb);
GRP = zeros(n_samples_GRF,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end

phi_actual = pos_phi_data.limb_phi';

if (n_samples ~= n_samples_GRF)
    disp('warning ! not same number of samples for GRF and phi');
end

%%
phi_init = phi_actual(1,:);
parms_locomotion.sigma_hip = 0; %0.15;
parms_locomotion.sigma_knee = -0.05;
parms_locomotion.sigma_p_hip = 0;
parms_locomotion.sigma_p_knee = 0;
simulated_limb_phi = compute_phi_complete_rule(GRF,GRP,pos_phi_data.phi_update_timestamp,phi_init,parms_locomotion);

%% Plots
i_limb_stance_patch=3;

f=figure;
set(zoom(f),'Motion','horizontal')

ax_phase_comp_sim = zeros(n_limb,1);
for i_limb = 1:n_limb
    ax_phase_comp_sim(i_limb,1)=subplot(2,n_limb/2,i_limb);
    title(['Limb ' num2str(i_limb)]);
    hold on;
    time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
    plot(time,phi_actual(:,i_limb));
    plot(time,simulated_limb_phi(:,i_limb));
    ylabel('Phase [rad]');
    xlabel('Time [s]');
    legend('Computed by Robotis','Simulated');
end
linkaxes(ax_phase_comp_sim,'x');
%%
xlim([0 30]);