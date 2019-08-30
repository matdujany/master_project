clear; close all; clc;
addpath('../2_load_data_code');

%Quad
% recordID = 108; 
% n_limb = 4;

recordID = 129; %130; 
n_limb = 6;


[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

[inverse_map,sigma_advanced] = get_inverse_map(parms_locomotion.direction,parms_locomotion.id_map_used);

n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);
phi = pos_phi_data.limb_phi;

if abs(n_samples_phi-n_samples_GRF)>1
    disp('Warning ! Number of samples dont agree');
    if n_samples_phi == n_samples_GRF+1
        phi = pos_phi_data.limb_phi(:,2:end);
    end
end
    
phi = phi';

% GRF = zeros(n_samples,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end

%filtered version:
size_mv_average = 10;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
GRF_filtered = zeros(size(GRF));
for i=1:n_limb
%     GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i)); %causal
    GRF_filtered(:,i) = filtfilt(filter_coeffs,1,GRF(:,i)); %non-causal
end

%%
order = 2;
framelen = 15;
% GRF_filtered = sgolayfilt(GRF,order,framelen);

threshold_unloading = 0.2; %Fukuhuara, figure 6, stance if more than 20% of maximal value
[value_unloading,max_value_GRF_limb] = determine_value_unloading(GRF,threshold_unloading);

%% computing N_dots
for i=1:n_limb
    N_dot(:,i) = 10^3*diff(GRF(:,i))./diff(data.time(:,i));
    N_dot_filtered(:,i) = 10^3*diff(GRF_filtered(:,i))./diff(data.time(:,i));
end

%% computing phase updates
phase_updates = zeros(size(phi)-[1 0]);
diff_phi = diff(phi);
diff_phi(diff_phi<-6) = diff_phi(diff_phi<-6)+2*pi;
for i=1:n_limb
    phase_updates(:,i) = 10^3*diff_phi(:,i)./diff(pos_phi_data.phi_update_timestamp)' - 2*pi*parms_locomotion.frequency;
%     phase_updates(:,i) = diff_phi(:,i)./0.021 - 2*pi*parms_locomotion.frequency;

end


%% computing Tegotae feedback terms values
GRF_advanced_term = (inverse_map*GRF')';

for i=1:n_limb
    simple_Tegotae(:,i) = -0.08*GRF(:,i).*cos(phi(:,i));
    advanced_Tegotae(:,i) = sigma_advanced * GRF_advanced_term(:,i) .*cos(phi(:,i));
    advanced_Tegotae_without_cos(:,i) = sigma_advanced * GRF_advanced_term(:,i);
end

advanced_Tegotae_dot = sigma_advanced*(inverse_map*N_dot')';
advanced_Tegotae_dot_filtered = sigma_advanced*(inverse_map*N_dot_filtered')';

%% plotting GRFs
i_limb_plot = 3;
time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;

xlims = [30 60]; %% in secs

f=figure;
linewidth = 1.2;
f.Color = 'w';
sgtitle(['Limb LC ' num2str(i_limb_plot)]);

%GRF
subplot(3,1,1);
hold on;
plot(time, GRF(:,i_limb_plot));
plot(time, GRF_filtered(:,i_limb_plot),'LineWidth',linewidth);
legend('Raw','Filtered');
plot([time(1) time(end)],[value_unloading(i_limb_plot) value_unloading(i_limb_plot)],'k--','HandleVisibility','off');
ylabel('Z Load [N]');
ylim([-2 13]);
xlim(xlims);
xlabel('Time [s]');
ax_grf=gca();
add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax_grf.YLim,time,'b');

% Ncos(phi)
subplot(3,1,2);
hold on;
plot(time, - GRF(:,i_limb_plot).*cos(phi(:,i_limb_plot)));
plot([time(1) time(end)],[0 0],'k--');
ylabel('- N * cos phi [N]');
ylim([-10 10]);
xlim(xlims);
xlabel('Time [s]');
ax_Ncosphi=gca();
add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax_Ncosphi.YLim,time,'b');

% Ndot
subplot(3,1,3);
hold on;
plot(time(2:end), N_dot(:,i_limb_plot));
plot(time(2:end), N_dot_filtered(:,i_limb_plot),'LineWidth',linewidth);
plot([time(1) time(end)],[0 0],'k--','HandleVisibility','off');
legend('Raw','Filtered');
ylabel('N\_dot [N/s]');
ylim(50*[-1 1]);
xlim(xlims);
xlabel('Time [s]');
ax_Ndot=gca();
add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax_Ndot.YLim,time,'b');

linkaxes([ax_grf ax_Ncosphi ax_Ndot],'x');

%% comparing N and Ndot
figure;
linewidth = 1.2;
hold on;
plot(time, - GRF(:,i_limb_plot).*cos(phi(:,i_limb_plot)),'LineWidth',linewidth);
plot(time(2:end), 0.2*N_dot_filtered(:,i_limb_plot),'LineWidth',linewidth);
plot([time(1) time(end)],[0 0],'k--','HandleVisibility','off');
legend('-N cos(phi)','N dot filtered');
ylabel('[N]');
ylim(7*[-1 1]);
xlim(xlims);
xlabel('Time [s]');
title(['Limb LC ' num2str(i_limb_plot)]);

ax_compareN=gca();
add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax_compareN.YLim,time,'b');
linkaxes([ax_grf ax_Ncosphi ax_Ndot ax_compareN],'x');

xlim([0 30]);


%% comparing Tegotae terms with phase update
figure;
i_limb_plot = 2;
time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
hold on;
plot(time(1:end-1), phase_updates(:,i_limb_plot),'k','LineWidth',linewidth);

% plot(time, simple_Tegotae(:,i_limb_plot),'LineWidth',linewidth);
% plot(time, advanced_Tegotae_without_cos(:,i_limb_plot),'LineWidth',linewidth);

% plot(time, advanced_Tegotae(:,i_limb_plot),'LineWidth',linewidth);

% plot(time(2:end), 0.02*N_dot(:,i_limb_plot),'LineWidth',linewidth);
plot(time(2:end), advanced_Tegotae_dot(:,i_limb_plot),'LineWidth',linewidth);
plot(time(2:end), advanced_Tegotae_dot_filtered(:,i_limb_plot),'LineWidth',linewidth);
% legend('Actual Phase update','Simple','Advanced','N dot','Advanced Tegotae dot');
% legend('Actual Phase update','Advanced','Advanced Tegotae dot with filtering');

% ylim(1.5*[-1 1]);
ylabel('phase update from control signal');
xlabel('Time');
title(['Control terms for Limb ' num2str(i_limb_plot)]);
ax_Tegotae=gca();
add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax_Tegotae.YLim,time,'b');

linkaxes([ax_grf ax_Ncosphi ax_Ndot ax_Tegotae],'x');
xlim([0 20]);


%% comparing Tegotae terms
figure;
sgtitle(['Limb LC ' num2str(i_limb_plot)]);
linewidth = 1.2;
time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
subplot(3,1,1);
hold on;
plot(time, simple_Tegotae(:,i_limb_plot),'b','LineWidth',linewidth);
plot(time, advanced_Tegotae(:,i_limb_plot),'r','LineWidth',linewidth);
plot(time, advanced_Tegotae_without_cos(:,i_limb_plot),'Color',[0.3 0.1 0.1],'LineWidth',linewidth);
legend('Simple','Advanced','Advanced without cos');
ylim(1.5*[-1 1]);
ylabel('phase update from control signal');
xlabel('Time');
ax_Tegotae1=gca();
add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax_Tegotae1.YLim,time,'b');

subplot(3,1,2);
hold on;
plot(time, simple_Tegotae(:,i_limb_plot),'b','LineWidth',linewidth);
plot(time(2:end), 0.02*N_dot_filtered(:,i_limb_plot),'b--','LineWidth',linewidth);
legend('Simple','N dot filtered');
ylim(1*[-1 1]);
ylabel('phase update from control signal');
xlabel('Time');
ax_Tegotae2=gca();
add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax_Tegotae2.YLim,time,'b');

subplot(3,1,3);
hold on;
plot(time, advanced_Tegotae(:,i_limb_plot),'r','LineWidth',linewidth);
plot(time(2:end), 0.02*advanced_Tegotae_dot_filtered(:,i_limb_plot),'r--','LineWidth',linewidth);
plot([time(1) time(end)],[0 0],'k--','HandleVisibility','off');
legend('Advanced','Advanced with N dot filtered');
ylim(1*[-1 1]);
ylabel('phase update [rad/s]');
xlabel('Time');
ax_Tegotae3=gca();
add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax_Tegotae3.YLim,time,'b');

linkaxes([ax_Tegotae1 ax_Tegotae2 ax_Tegotae3],'x');
xlim([78 94]);


%% comparing N dot to the N dots 

i_reference_leg = 2;
ax_comp=zeros(6,1);
figure;
sgtitle(['Contributions to Advanced Tegotae Rule - Ref leg ' num2str(i_reference_leg)]);
for i=1:n_limb
    subplot(n_limb/2,2,i);
    hold on;
    time = (data.time(:,i)-data.time(1,i))/10^3;
    plot(time,-GRF(:,i).*cos(phi(:,i_reference_leg)));
    plot(time(2:end), 0.2*N_dot_filtered(:,i));
    legend(' - Ncos(phi_{ref})','N dot filtered');
    ylabel(['Leg ' num2str(i)]);
    xlabel('Time');
    ylim(7.5*[-1 1]);
    ax_temp=gca();
    add_stance_patches_GRF(GRF(:,i_reference_leg),threshold_unloading,ax_temp.YLim,time,'b');
    ax_comp(i) = ax_temp;
end
linkaxes(ax_comp,'x');
xlim([78 94]);


%% comparing phi command position.
%% plotting positions
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion,n_limb,recordID);

command_pos_c1 = phase2pos_wrapper(pos_phi_data.limb_phi(i_limb_plot,:)+pi/2,0,changeDir(i_limb_plot,1),parms_locomotion);
command_pos_c2 = phase2pos_wrapper(pos_phi_data.limb_phi(i_limb_plot,:),1,changeDir(i_limb_plot,2),parms_locomotion);
figure;
sgtitle(['Limb ' num2str(i_limb_plot)]);
subplot(2,1,1);
hold on;
plot(pos_phi_data.motor_timestamps(limb_ids(i_limb_plot,1),:)/10^3,command_pos_c1);
plot(pos_phi_data.motor_timestamps(limb_ids(i_limb_plot,1),:)/10^3,pos_phi_data.motor_position(limb_ids(i_limb_plot,1),:));
legend('Command','Actual');
ylim([400 600]);
ax1=gca();
add_stance_patches_GRF(GRF(:,i_reference_leg),threshold_unloading,ax_temp.YLim,time,'b');
ylabel('Motor Position Class 1');
xlabel('Time [s]');

subplot(2,1,2);
hold on;
plot(pos_phi_data.motor_timestamps(limb_ids(i_limb_plot,2),:)/10^3,command_pos_c2);
plot(pos_phi_data.motor_timestamps(limb_ids(i_limb_plot,2),:)/10^3,pos_phi_data.motor_position(limb_ids(i_limb_plot,2),:));
legend('Command','Actual');
ylim([400 600]);
ax2=gca();
add_stance_patches_GRF(GRF(:,i_reference_leg),threshold_unloading,ax_temp.YLim,time,'b');
ylabel('Motor Position Class 2');
xlabel('Time [s]');

linkaxes([ax1 ax2],'x');
xlim([50 80]);


