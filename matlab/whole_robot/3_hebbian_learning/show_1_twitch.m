clear; 
close all; clc;

addpath('../2_load_data_code');

%% Load data
recordID = 110;
[data, lpdata, parms] =  load_data_processed(recordID);
% add_parms;

%%
good_closest_LC = [3;3;4;4;1;1;2;2];%just to pick motor and loadcells which are related.

n_iter = 3;
index_motor_plot = 1;
index_loadcell_plot = good_closest_LC(index_motor_plot);

n_frames_part0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_part2 = floor(parms.duration_part2/parms.time_interval_twitch);

nb_theo_frames_per_twitch = (n_frames_part0+n_frames_part1+n_frames_part2)*(parms.n_m*parms.n_dir);

index_start = 1+nb_theo_frames_per_twitch*(n_iter-1) + (n_frames_part0+n_frames_part1+n_frames_part2)*(index_motor_plot-1)*parms.n_dir;
index_end = nb_theo_frames_per_twitch*(n_iter-1)  + (n_frames_part0+n_frames_part1+n_frames_part2)*(index_motor_plot)*parms.n_dir;

data = compute_filtered_signal_data(data,parms);
lpdata = compute_filtered_signal_lpdata(lpdata,parms);

%% time signals
figure;
for channel=1:3
    subplot(2,2,channel);
    hold on;
    plot(lpdata.motor_position(index_motor_plot,index_start:index_end),'b-');
    plot(lpdata.motor_positionfiltered(index_motor_plot,index_start:index_end),'b--');
    xlabel('Frame index');
    ylabel(['Motor ' num2str(index_motor_plot) ' Position']);
%     for i=1:parms.n_m
%      plot(lpdata.motor_position(i,index_start:index_end));
%     end
    yyaxis right;
    %plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,channel),'--');
    plot(data.float_value_time{1,index_loadcell_plot}(index_start:index_end,channel),'r-');
    plot(data.s_lc_filtered(index_start:index_end,channel+3*(index_loadcell_plot-1)),'r--');
    ylabel(['Loadcell channel ' num2str(channel) ' value [N]']);
    hold off;
    ax=gca();
    ax.YAxis(1).Color = 'r';
    ax.YAxis(2).Color = 'b';
end

%% dot time signals
figure;
for channel=1:3
    subplot(2,2,channel);
    hold on;
    plot(lpdata.m_s_dot_pos(index_motor_plot,index_start:index_end),'b-');
    plot(lpdata.m_s_dot_posfiltered(index_motor_plot,index_start:index_end),'b--');
    xlabel('Frame index');
    ylabel(['Motor ' num2str(index_motor_plot) ' speed']);
    ylim([-0.1 0.1]);
    yyaxis right;
    plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,channel),'r-');
    plot(data.s_dot_lc_filtered(index_start:index_end,channel+3*(index_loadcell_plot-1)),'r--');
    ylabel(['Loadcell channel ' num2str(channel) ' differentiated value [N/s]']);
    ylim([-100 100]);
    ax=gca();
    ax.YAxis(1).Color = 'r';
    ax.YAxis(2).Color = 'b';
    hold off;   
end

%%
%weights=read_weights_robotis(recordID,parms);
%hinton_LC(weights{parms.n_twitches},parms);
