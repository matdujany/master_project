clear; close all; clc;
addpath('../2_load_data_code');

recordID = 10;
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

[limbs,limb_ids,changeDir,offset_knee_to_hip] = get_hardcoded_limb_values(parms_locomotion);
n_limb = size(limbs,1);
n_samples = size(pos_phi_data.limb_phi,2);

GRF = zeros(n_samples,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
end

%% plotting GRFs
figure;
hold on;
for i=1:n_limb
    time = (data.time(:,i)-data.time(1,i))/10^3;
    plot(time, GRF(:,i));
    legend_list{i} = ['LC ' num2str(i)];
end
i_limb_stance_patch=3;
plot_stance_patches(pos_phi_data.limb_phi(i_limb_stance_patch,:),gca(),(data.time(:,i_limb_stance_patch)-data.time(1,i_limb_stance_patch))/10^3);
legend(legend_list);
ylabel('Loadcell Z Channel [N]');
ylim([-2 12]);
xlabel('Time [s]');
title(['Patches : limb ' num2str(i_limb_stance_patch) ' in stance according to its phase']);


%% plotting positions
figure;
for i_limb = 1:n_limb
    subplot(2,2,i_limb)
    hold on;
    plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,1),:)/10^3,pos_phi_data.motor_position(limb_ids(i_limb,1),:),'b');
    plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,2),:)/10^3,pos_phi_data.motor_position(limb_ids(i_limb,2),:),'k');
    command_pos_hip = phase2pos_hipknee_wrapper(pos_phi_data.limb_phi(i_limb,:),1,changeDir(i_limb,1),parms_locomotion);
    command_pos_knee = phase2pos_hipknee_wrapper(pos_phi_data.limb_phi(i_limb,:)+offset_knee_to_hip(i_limb),0,changeDir(i_limb,2),parms_locomotion);
    plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,1),:)/10^3,command_pos_hip,'b--');
    plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,2),:)/10^3,command_pos_knee,'k--');    
    ylim([400 600]);
    plot_stance_patches(pos_phi_data.limb_phi(i_limb,:),gca(),pos_phi_data.motor_timestamps(limb_ids(i_limb,1),:)/10^3);
    legend({['Hip, ID ' num2str(limbs(i_limb,1))],['Knee, ID ' num2str(limbs(i_limb,2))]});
    ylabel('Motor Position');
    xlabel('Time [s]');
    title(['Limb ' num2str(i_limb)]);
end


%%
simulated_limb_phi = compute_phi(pos_phi_data,GRF,parms_locomotion);

%%
i_limb_stance_patch=3;

figure;
subplot(2,1,1);
title('Computed by robotis');
for i_limb = 1:n_limb
    hold on;
    time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
    plot(time,mod(pos_phi_data.limb_phi(i_limb,:),2*pi));
    ylabel('Phase [rad]');
    xlabel('Time [s]');
    legend_list{i_limb} = ['Limb ' num2str(i_limb)];
end
legend(legend_list);
subplot(2,1,2);
title('Simulated');
for i_limb = 1:n_limb
    hold on;
    time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
    plot(time,mod(simulated_limb_phi(i_limb,:),2*pi));
    ylabel('Phase [rad]');
    xlabel('Time [s]');
    legend_list{i_limb} = ['Limb ' num2str(i_limb)];
end
plot_stance_patches(pos_phi_data.limb_phi(i_limb_stance_patch,:),gca(),pos_phi_data.phi_update_timestamp(1,:)/10^3);
legend(legend_list);