%gait plot

clear; close all; clc;
addpath('../2_load_data_code');
addpath('../../export_fig');
addpath('plot_functions');

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

%%
recordID = 155; %148
n_limb = 6;

% recordID = 34;
% n_limb = 6;

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

[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion,n_limb,recordID);
n_limb = size(limbs,1);

n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);

if abs(n_samples_phi-n_samples_GRF)>1
    disp('Warning ! Number of samples dont agree');
end

% GRF = zeros(n_samples,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end

%filtered version:
size_mv_average = 6;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
GRF_filtered = zeros(size(GRF));
for i=1:n_limb
    GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i));
end

% GRF = GRF_filtered;

%%
threshold_unloading = 0.3; %Fukuhuara, figure 6, stance if more than 20% of maximal value
[value_unloading,max_value_GRF_limb] = determine_value_unloading(GRF,threshold_unloading);

%% plotting GRFs
time = (data.time(:,:)-data.time(1,:))/10^3;
[f_GRF,ax_grf] = plot_GRF(GRF,time,threshold_unloading,recordID);

%% gait diagramm
[f_gait,ax_gait] = plot_gait_diagram(GRF,time,threshold_unloading,recordID);

%% phases
[f_phase,ax_phase] = plot_phases(pos_phi_data,recordID);

%% total load;
f_total_load = figure;
time = (data.time(:,1)-data.time(1,1))/10^3;
plot(time,sum(GRF_filtered,2));
f_total_load.Position = [57.4         94.2         1184        302.4];
ax_total_load =gca();
ax_total_load.FontSize = fontSizeTicks;

set(zoom(f_total_load),'Motion','horizontal');

figure;
subplot(1,2,1);
title('Load on the right');
plot(sum(GRF(:,1:n_limb/2),2));
subplot(1,2,2);
title('Load on the left');
plot(sum(GRF(:,n_limb/2+1:end),2));

%% delta phases
phi = pos_phi_data.limb_phi;
delta_phases = compute_delta_phases(phi);
time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
[f_delta_phases,ax_delta_phases] = plot_delta_phases(time,delta_phases,recordID);

%%
linkaxes([ax_grf;ax_gait;ax_phase;ax_total_load; ax_delta_phases],'x');
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

