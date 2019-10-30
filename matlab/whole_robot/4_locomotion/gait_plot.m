%gait plot

clear; close all; clc;
addpath('../2_load_data_code');
addpath('plot_functions');

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

%%
recordID = 303; %148
n_limb = 6;

% recordID = 108;
% n_limb = 4;

% recordID = 50;
% n_limb = 8;

% recordID = 34;
% n_limb = 6;
% 
% recordID = 145;
% n_limb = 6;
% 
% recordID = 108;
% n_limb = 4;


[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
% parms_locomotion = add_parms_change_recordings(parms_locomotion,recordID);

[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion.direction,n_limb,recordID);
n_limb = size(limbs,1);

n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);

if abs(n_samples_phi-n_samples_GRF)>1
    disp('Warning ! Number of samples dont agree');
end

GRF = zeros(n_samples_GRF,n_limb);
GRP = zeros(n_samples_GRF,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end

%filtered version:
size_mv_average = 6;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
GRF_filtered = zeros(size(GRF));
GRP_filtered = zeros(size(GRP));

for i=1:n_limb
    GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i));
    GRP_filtered(:,i) = filter(filter_coeffs,1,GRP(:,i));

end

% GRF = GRF_filtered;

%%
threshold_unloading = 0.4; %Fukuhuara, figure 6, stance if more than 20% of maximal value
[value_unloading,max_value_GRF_limb] = determine_value_unloading(GRF,threshold_unloading);

%% plotting GRFs
time_GRF = (data.time(:,:)-data.time(1,:))/10^3;
[f_GRF,ax_grf] = plot_GRF(GRF,time_GRF,threshold_unloading,recordID);

[f_GRP,ax_grp] = plot_GRP(GRP,time_GRF,GRF,threshold_unloading,recordID);

%% gait diagramm
[f_gait,ax_gait] = plot_gait_diagram(GRF,time_GRF,threshold_unloading,recordID);

%% phases
[f_phase,ax_phase] = plot_phases(pos_phi_data,recordID,GRF,time_GRF(:,1));

%% total load;
% f_total_load = figure;
% time = (data.time(:,1)-data.time(1,1))/10^3;
% plot(time,sum(GRF,2));
% f_total_load.Position = [57.4         94.2         1184        302.4];
% ax_total_load =gca();
% ax_total_load.FontSize = fontSizeTicks;
% 
% set(zoom(f_total_load),'Motion','horizontal');
% 
% figure;
% subplot(1,2,1);
% title('Load on the right');
% plot(sum(GRF(:,1:n_limb/2),2));
% subplot(1,2,2);
% title('Load on the left');
% plot(sum(GRF(:,n_limb/2+1:end),2));

%% delta phases
phi = pos_phi_data.limb_phi;
delta_phases = compute_delta_phases(phi);
time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
[f_delta_phases,ax_delta_phases] = plot_delta_phases(time,delta_phases,recordID);

%%
ax_sum = zeros(2,1);
figure;
subplot(1,2,1);
plot(time_GRF(:,1), sum(GRF_filtered.^2,2));
ax_sum(1,1)=gca();
xlabel('Time [s]');
ylabel('Sum GRF^2 [N^2]');
ylim([0 250]);
subplot(1,2,2);
plot(time_GRF(:,1), sum(GRP_filtered.^2,2));
ax_sum(2,1)=gca();
xlabel('Time [s]');
ylabel('Sum GRP^2 [N^2]');
ylim([0 50]);

%%
linkaxes([ax_grf;ax_grp;ax_gait;ax_phase; ax_delta_phases; ax_sum],'x');
% linkaxes([ax_grf;ax_grp;ax_gait;ax_phase; ax_delta_phases],'x');

xlim([0 120]);

%% plotting positions
% ax_positions = zeros(n_limb,1);
% neutral_pos = read_neutral_pos(parms_locomotion.id_map_used,parms.n_m);
% f_pos=figure;
% for index_limb = 1:n_limb
% %     if mod(index_limb-1,4) == 0
% %         f_pos=figure;
% %     end
%
%     i_limb = limb_list_ordered(index_limb);
%     ax_positions(index_limb,1)= subplot(n_limb/2,2,index_subplots(index_limb));
%
%     hold on;
%
%     plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,1),:)/10^3,1/3.413*(pos_phi_data.motor_position(limb_ids(i_limb,1),:)-neutral_pos(limb_ids(i_limb,1))),'b','LineWidth',lineWidth);
%     plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,2),:)/10^3,1/3.413*(pos_phi_data.motor_position(limb_ids(i_limb,2),:)-neutral_pos(limb_ids(i_limb,2))),'k','LineWidth',lineWidth);
% %     command_pos_c1 = phase2pos_wrapper(pos_phi_data.limb_phi(i_limb,:)+offset_class1(i_limb),0,changeDir(i_limb,1),parms_locomotion);
% %     command_pos_c2 = phase2pos_wrapper(pos_phi_data.limb_phi(i_limb,:),1,changeDir(i_limb,2),parms_locomotion);
% %
% %     plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,1),:)/10^3,command_pos_c1-512,'b--');
% %     plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,2),:)/10^3,command_pos_c2-512,'k--');
%     ylim([-25 25]);
% %     plot_stance_patches_phi(pos_phi_data.limb_phi(i_limb,:),gca(),pos_phi_data.motor_timestamps(limb_ids(i_limb,1),:)/10^3);
%     ax=gca();
%     ax.FontSize = fontSizeTicks;
%     add_stance_patches_GRF(GRF(:,i_limb),threshold_unloading,ax.YLim,time,'b');
% %     legend({['Class 1 (movement effector), M' num2str(limb_ids(i_limb,1)) ', ID ' num2str(limbs(i_limb,1))],        ['Class 2 (swing/stance), M' num2str(limb_ids(i_limb,2)) ', ID ' num2str(limbs(i_limb,2))]});
%     lgd=legend({['M' num2str(limb_ids(i_limb,1))],['M' num2str(limb_ids(i_limb,2))]});
%     lgd.Location = 'eastoutside';
%     lgd.FontSize =fontSize;
%     grid on;
%     ylabel('Positions [deg]');
%     xlabel('Time [s]');
%     title([limb_names_ordered{index_limb} ' (Limb ' num2str(i_limb) ')']);
%
% end
% f_pos.Color = 'w';
% f_pos.Position = 10^3*[ 0.0018    0.3750    1.1752    0.4076];
%
% %%
% linkaxes([ax_grf;ax_gait;ax_phase;ax_total_load; ax_delta_phases;ax_positions ],'x');

%%
if recordID == 26
    t_start_0_15 = 84.4;
    t_stop_0_15 = 112.3;
    duty_factor_0_15 = compute_duty_factor(GRF,data,t_start_0_15,t_stop_0_15,threshold_unloading);
    
    t_start_0_5 = 160.3;
    t_stop_0_5 = 174.6;
    duty_factor_0_5 = compute_duty_factor(GRF,data,t_start_0_5,t_stop_0_5,threshold_unloading);
end

%%
if false
    export_fig(['figures_report_locomotion/delta_phases_' num2str(recordID) '.pdf'],f_delta_phases);
end

if false
    export_fig(['figures_report_locomotion/gait_diagram_' num2str(recordID) '.pdf'],f_gait);
end

if false
    export_fig(['figures_report_locomotion/phases_' num2str(recordID) '.pdf'],f_phase);
end

if false
    %     export_fig(['figures_report_locomotion/motor_positions_' num2str(recordID) '.pdf'],f_pos);
    f_pos.PaperOrientation = 'landscape';
    print(f_pos, '-dpdf', '-bestfit', ['figures_report_locomotion\motor_positions_' num2str(recordID) '.pdf']);
end

if false
    %     export_fig(['figures_report_locomotion/GRF_' num2str(recordID) '.pdf'],f_GRF);
    f_GRF.PaperOrientation = 'landscape';
    print(f_GRF, '-dpdf', '-bestfit', ['figures_report_locomotion\GRF_' num2str(recordID) '.pdf']);
end

%%
final_delta_phases = mean(delta_phases(:,:,end-50:end),3);
phi_init_test = final_delta_phases(:,1);

%% integrals
index_limb_phase = 1;
phi = pos_phi_data.limb_phi;
[pk_values,idx_peaks]=findpeaks(phi(index_limb_phase,:));
set(0, 'CurrentFigure', f_phase)
set(gcf, 'CurrentAxes', ax_phase(1));

hold on;
time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
scatter(time(idx_peaks),pk_values,'ko','HandleVisibility','off');
for i=1:length(idx_peaks)
        text(time(idx_peaks(i)),2*pi+0.5,num2str(i),'FontSize',12,'HorizontalAlignment','center');
end

first_peak_integral = 13; %36; %27;
last_peak_integral = 21; %43; %34;
scatter(time(idx_peaks(first_peak_integral)),pk_values(first_peak_integral),'ro','HandleVisibility','off');
scatter(time(idx_peaks(last_peak_integral)),pk_values(last_peak_integral),'ro','HandleVisibility','off');

indexes_integral = idx_peaks(first_peak_integral)+1:idx_peaks(last_peak_integral);

index_check= find(sum(GRF(indexes_integral,:),2) < 10);
if ~isempty(index_check)
    disp('Warning ! the indexes selected contain samples where the robot is in the air');
    figure;
    hold on;
    plot(time_GRF(:,1),sum(GRF,2));
    plot(time(idx_peaks(first_peak_integral))*[1 1],[0 20],'k--');
    plot(time(idx_peaks(last_peak_integral))*[1 1],[0 20],'k--');
    return;
end

xlim([time(idx_peaks(first_peak_integral)) time(idx_peaks(last_peak_integral))]);


%%
GRF_ref = zeros(1,n_limb);
[integrals,integrals_squared,integrals_GRF_ref,integrals_GRF_ref_squared] = compute_gait_integrals(indexes_integral,GRF,GRF_ref,data.time);
% [integrals_GRP,integrals_squared_GRP,integrals_GRP_ref,~] = compute_gait_integrals(indexes_integral,GRP,zeros(1,n_limb),data.time);
integrals_GRF_squared_stance = compute_gait_integrals_GRF(indexes_integral,GRF,phi,data.time);

metric_sumNsquared = sum(integrals_squared)
metric_sumNsquared_stance = sum(integrals_GRF_squared_stance)
