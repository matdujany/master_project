%to compute the limb phis using the advanced rule

clear; close all; clc;
addpath('../2_load_data_code');

recordID = 181;
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

n_limb = 6;
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion.direction,n_limb,recordID);
n_limb = size(limbs,1);
n_samples = size(pos_phi_data.limb_phi,2);

GRF = zeros(n_samples,n_limb);
GRP = zeros(n_samples,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end


%% if amputation
% GRF_amputated = GRF;
% t_removed = [40];
% lc_amputated = [4] + 1;
% for i=1:length(t_removed)
%     index_start = find(pos_phi_data.phi_update_timestamp > t_removed(i)*10^3);
%     GRF_amputated(index_start:end,lc_amputated(i)) = 0;
% end

%%
parms_locomotion.frequency = 0.5
parms_locomotion = add_parms_change_recordings(parms_locomotion,recordID);
simulated_limb_phi = compute_phi_wrapper(pos_phi_data,GRF,parms_locomotion);

simulated_limb_phi = compute_phi_complete_rule(pos_phi_data,GRF,parms_locomotion);

phi_init
simulated_limb_phi = compute_phi_complete_rule(GRF,GRP,phi_update_timestamps,phi_init,parms_locomotion)

%% Phases
i_limb_stance_patch=3;

f=figure;
set(zoom(f),'Motion','horizontal')
sgtitle('Computed by robotis');
for i_subplot =1:2
    subplot(2,1,i_subplot);
    for i_limb = 1:n_limb
        hold on;
        time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
        plot(time,mod(pos_phi_data.limb_phi(i_limb,:),2*pi),'LineWidth',1.5);
        ylabel('Phase [rad]');
        xlabel('Time [s]');
        legend_list{i_limb} = ['Limb ' num2str(i_limb)];
    end
    legend(legend_list);
end

% plot_stance_patches_phi(pos_phi_data.limb_phi(i_limb_stance_patch,:),gca(),pos_phi_data.phi_update_timestamp(1,:)/10^3);
% add_stance_patches_GRF(GRF(:,i_limb_stance_patch),gca(),(data.time(:,i_limb)-data.time(1,i_limb))/10^3,'b');

ax_phase_comp_sim = zeros(n_limb,1);
for i_limb = 1:n_limb
    if mod(i_limb-1,4) == 0
        f=figure;
    end
    ax_phase_comp_sim(i_limb,1)=subplot(2,2,mod(i_limb-1,4)+1);
    title(['Limb ' num2str(i_limb)]);
    hold on;
    time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
    plot(time,mod(pos_phi_data.limb_phi(i_limb,:),2*pi));
    plot(time,mod(simulated_limb_phi(i_limb,:),2*pi));
    ylabel('Phase [rad]');
    xlabel('Time [s]');
    legend('Computed by Robotis','Simulated');
    set(zoom(f),'Motion','horizontal')
end
linkaxes(ax_phase_comp_sim,'x');
