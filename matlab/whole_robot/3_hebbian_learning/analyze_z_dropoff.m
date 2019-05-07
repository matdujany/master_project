
clear;
close all; clc;

addpath('hinton_plot_functions');
addpath('computing_functions');
addpath('../2_load_data_code');
addpath('../../tight_subplot');


%% Load data
recordID = 86;
[data, lpdata, parms] =  load_data_processed(recordID);
parms = add_parms(parms);
weights = read_weights_robotis(recordID,parms);
weights_pos = read_weights_pos_robotis(recordID,parms);

%%
% hinton_pos(weights_pos{parms.n_twitches},parms,0);
hinton_LC(weights{parms.n_twitches},parms);
% hinton_IMU(weights{parms.n_twitches},parms);
% hinton_full(weights,weights_pos,parms);

%% computing learning signals
data = compute_filtered_signal_data(data,parms);
s_dot_lc = data.s_dot_lc_filtered;
s_IMU = data.s_IMU_filtered;
[m_dot_values,m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,1);

%% s dot
% subplots_z_loadcells(idx_twitch,s_dot_lc,parms);
% 
% list_hip_motors = [1 2 5 6 9 10 13 14];
% subplots_z_loadcells(idx_twitch,s_dot_lc,parms,list_hip_motors);
% 
%% raw s 
s_lc = zeros(data.count_frames,3*parms.n_lc);
for i_lc=1:parms.n_lc
    s_lc(:,[1:3]+3*(i_lc-1))=data.float_value_time{1,i_lc};
end
% list_part_motors = [1:24];
% subplots_z_loadcells(idx_twitch,s_lc,parms,list_part_motors);

%%
flagPlot = 1;
threshold_factor = 0.2;
[totalcounts, min_dropoffs] = count_dropoffs(threshold_factor,data,parms,flagPlot);

%%
i_lc_part_plot = 3; %6;
i_motor_part_plot = 6;%5;
i_dir = 1;
figure;
count = 1;
for i_twitch_part_plot=[1 3 5]
    subplot(1,3,count);
    plot_lc_motor_part(i_lc_part_plot,i_motor_part_plot,i_dir,i_twitch_part_plot,s_lc,lpdata,threshold_factor,parms);
    count = count+1;
end

%%
dropoffs_summed = sum(totalcounts,3);
motor_ids_dropoff = zeros(parms.n_lc,1);
direction_dropoff = zeros(parms.n_lc,1);
for i=1:parms.n_lc
    [~, idx_raw] = max(dropoffs_summed(i,:));
    motor_ids_dropoff(i,1) = ceil(idx_raw/2);
    direction_dropoff(i,1) = -2*mod(idx_raw,2)+1;
end

function plot_lc_motor_part(i_lc,i_motor,i_dir,i_twitch,s_lc,lpdata,threshold_factor,parms)
% figure;
lineWidth = 1.2;
y_min = -2;
y_max = 6;
y_patch_learning = [y_min y_min y_max y_max];
n_frames_theo = get_theo_number_frames(parms);
index_start_twitch = 1+n_frames_theo.per_twitch*(i_twitch-1);
x_patch_learning = [n_frames_theo.part0+1 n_frames_theo.part0+n_frames_theo.part1  n_frames_theo.part0+n_frames_theo.part1 n_frames_theo.part0+1];

index_start = index_start_twitch+2*n_frames_theo.per_action*(i_motor-1)+n_frames_theo.per_action*(i_dir-1);
index_end = index_start + n_frames_theo.per_action-1;
data_loadz = s_lc(index_start:index_end,3*i_lc);

hold on;
plot(data_loadz,'b-','LineWidth',lineWidth);
plot(myfilter(data_loadz,6),'b--','LineWidth',lineWidth);
patch(x_patch_learning,y_patch_learning,'blue','FaceAlpha',0.1,'EdgeColor','none');
plot([0 n_frames_theo.per_action-1],[0 0]);
xlim([n_frames_theo.part0-10 n_frames_theo.part0+n_frames_theo.part1+10]);
ylim([y_min y_max]);
ylabel(['LC ' num2str(i_lc) ' Z load']);

mean_load_p0 = mean(data_loadz(1:n_frames_theo.part0));
total_count = 0;
threshold_load_value = threshold_factor*mean_load_p0;
plot(n_frames_theo.part0+[1 n_frames_theo.part1],[threshold_load_value threshold_load_value],'k--');
bool_dropoff = false;
min_dropoff = 0;
for i_frame = 1:n_frames_theo.part1
    delta= data_loadz(n_frames_theo.part0+i_frame)-data_loadz(n_frames_theo.part0+i_frame-1);
    if delta < min_dropoff
        min_dropoff = delta;
    end
    if delta < - 0.5*mean_load_p0
        bool_dropoff = true;
        x_patch_dropoff = n_frames_theo.part0+[i_frame-1 i_frame i_frame i_frame-1];
        value_1 = data_loadz(n_frames_theo.part0+i_frame-1);
        value_2 = data_loadz(n_frames_theo.part0+i_frame);
        y_patch_dropoff = [value_1 value_1 value_2 value_2];
        patch(x_patch_dropoff,y_patch_dropoff,'white','EdgeColor','r','FaceAlpha',0);
    end
    if bool_dropoff && data_loadz(n_frames_theo.part0+i_frame)<threshold_load_value
        total_count = total_count + 1;
    end
end

yyaxis right;
hold on;
plot(lpdata.motor_position(i_motor,index_start:index_end));
theoretical_traj = compute_theoretical_traj_wrapper(i_dir,parms);
plot(theoretical_traj);
ylabel(['Motor ' num2str(i_motor) ' Position']);
title(['Twitch ' num2str(i_twitch) ', total counts ' num2str(total_count)]);
ylim([min(theoretical_traj)-5 max(theoretical_traj)+5]);
end