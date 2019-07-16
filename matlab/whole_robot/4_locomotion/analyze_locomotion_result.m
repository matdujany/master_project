clear; close all; clc;
addpath('../2_load_data_code');

recordID = 125;
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

n_limb = 6;
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion,n_limb,recordID);
n_limb = size(limbs,1);
n_samples = size(pos_phi_data.limb_phi,2);

% GRF = zeros(n_samples,n_limb);
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
legend(legend_list);
ylabel('Loadcell Z Channel [N]');
ylim([-2 20]);
xlim([0 60]);
xlabel('Time [s]');
% i_limb_stance_patch=3;
% plot_stance_patches(pos_phi_data.limb_phi(i_limb_stance_patch,:),gca(),(data.time(:,i_limb_stance_patch)-data.time(1,i_limb_stance_patch))/10^3);
% title(['Patches : limb ' num2str(i_limb_stance_patch) ' in stance according to its phase']);

%filtered version:
size_mv_average = 5;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
figure;
hold on;
for i=1:n_limb
    time = (data.time(:,i)-data.time(1,i))/10^3;
    plot(time, filter(filter_coeffs,1,GRF(:,i)));
    legend_list{i} = ['LC ' num2str(i)];
end
legend(legend_list);
ylabel('Loadcell Z Channel Filtered[N]');
ylim([-2 20]);
xlim([0 60]);
xlabel('Time [s]');
% i_limb_stance_patch=3;
% plot_stance_patches(pos_phi_data.limb_phi(i_limb_stance_patch,:),gca(),(data.time(:,i_limb_stance_patch)-data.time(1,i_limb_stance_patch))/10^3);
% title(['Patches : limb ' num2str(i_limb_stance_patch) ' in stance according to its phase']);


%% plotting positions
for i_limb = 1:n_limb
    if mod(i_limb-1,4) == 0
        figure;
    end
    subplot(2,2,mod(i_limb-1,4)+1)
    hold on;
    plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,1),:)/10^3,pos_phi_data.motor_position(limb_ids(i_limb,1),:),'b');
    plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,2),:)/10^3,pos_phi_data.motor_position(limb_ids(i_limb,2),:),'k');
    command_pos_c1 = phase2pos_wrapper(pos_phi_data.limb_phi(i_limb,:)+offset_class1(i_limb),0,changeDir(i_limb,1),parms_locomotion);
    command_pos_c2 = phase2pos_wrapper(pos_phi_data.limb_phi(i_limb,:),1,changeDir(i_limb,2),parms_locomotion);
    plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,1),:)/10^3,command_pos_c1,'b--');
    plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,2),:)/10^3,command_pos_c2,'k--');    
    ylim([400 600]);
%     plot_stance_patches_phi(pos_phi_data.limb_phi(i_limb,:),gca(),pos_phi_data.motor_timestamps(limb_ids(i_limb,1),:)/10^3);
    ax=gca();
    add_stance_patches_GRF(GRF(:,i_limb),ax.YLim,(data.time(:,i_limb)-data.time(1,i_limb))/10^3);
    legend({['Class 1 (movement effector), M' num2str(limb_ids(i_limb,1)) ', ID ' num2str(limbs(i_limb,1))],...
        ['Class 2 (swing/stance), M' num2str(limb_ids(i_limb,2)) ', ID ' num2str(limbs(i_limb,2))]});
    ylabel('Motor Position');
    xlabel('Time [s]');
    title(['Limb ' num2str(i_limb)]);
end


%% if amputation
% GRF_amputated = GRF;
% t_removed = [0, 0, 0, 60];
% lc_amputated = [0, 2, 1, 3] + 1;
% for i=1:length(t_removed)
%     index_start = find(pos_phi_data.phi_update_timestamp > t_removed(i)*10^3);
%     GRF_amputated(index_start:end,lc_amputated(i)) = 0;
% end

%%
parms_locomotion.frequency = 0.5
parms_locomotion = add_parms_change_recordings(parms_locomotion,recordID);
simulated_limb_phi = compute_phi_wrapper(pos_phi_data,GRF,parms_locomotion);

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

%% show unloading
for i_limb = 1:n_limb
    if mod(i_limb-1,4) == 0
        figure;
    end
    subplot(2,2,mod(i_limb-1,4)+1);
    title(['Limb ' num2str(i_limb)]);
    plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,2),:)/10^3,pos_phi_data.motor_position(limb_ids(i_limb,2),:),'k');
    ylabel('Class 2 (swing/stance) Motor Position');
    ylim(512+3.413*parms_locomotion.amplitude_class2_deg*[-1.2 1.2]);
    xlabel('Time [s]');
    yyaxis right;
    time = (data.time(:,i_limb)-data.time(1,i_limb))/10^3;
    plot(time, GRF(:,i_limb));
    ylim([-2 12]);
    ylabel('Loadcell channel Z [N]');
    plot_stance_patches_phi(pos_phi_data.limb_phi(i_limb,:),gca(),pos_phi_data.phi_update_timestamp(1,:)/10^3);
    title(['Limb ' num2str(i_limb)]);    
end
sgtitle('Blue patches show stance (computed according to phase), the peaks of load values should be centered on the blue patches');

