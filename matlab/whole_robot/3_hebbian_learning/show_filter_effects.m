clear; 
close all; clc;

addpath('../2_get_data_code');

%% Load data
recordID = 1;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;

%%
good_closest_LC = [3;3;4;4;1;1;2;2];%just to pick motor and loadcells which are related.

n_iter = 4;
index_motor_plot = 1;
index_loadcell_plot = 3;

n_frames_part0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_part2 = floor(parms.duration_part2/parms.time_interval_twitch);

nb_theo_frames_per_twitch = (n_frames_part0+n_frames_part1+n_frames_part2)*(parms.n_m*parms.n_dir);

index_start = 1+nb_theo_frames_per_twitch*(n_iter-1) + (n_frames_part0+n_frames_part1+n_frames_part2)*(index_motor_plot-1)*parms.n_dir;
index_end = nb_theo_frames_per_twitch*(n_iter-1)  + (n_frames_part0+n_frames_part1+n_frames_part2)*(index_motor_plot)*parms.n_dir;

flagFilter = 0;
[m_dot_learning,m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,flagFilter);
%%
sensor_value = data.float_value_time{1,index_loadcell_plot}(index_start:index_end,1:3);
sensor_value_filtered = myfilter(sensor_value);
i_part_value = lpdata.i_part(index_start:index_end);
sensor_value_filtered_part = filter_by_parts(sensor_value,i_part_value);

sensor_value_dot_filtered=10^3*diff(sensor_value_filtered)./diff(data.time(index_start:index_end,index_loadcell_plot));

s_dot = data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,1:3);
s_dot_filtered = myfilter(s_dot);

m_dot_values = 10^3*m_dot_learning(index_start:index_end);
m_dot_filtered = myfilter(m_dot_values);
motorpos_values = (lpdata.motor_position(index_motor_plot,index_start:index_end))';
m_values_filtered = myfilter(motorpos_values);
m_values_filtered_dot = 10^3*diff(m_values_filtered)./(diff(lpdata.motor_timestamp(index_motor_plot,index_start:index_end))');

index_start_learning1 = n_frames_part0+1;
index_stop_learning1 = n_frames_part0 + n_frames_part1;
index_start_learning2 = n_frames_part0 + n_frames_part1+n_frames_part2+n_frames_part0+1;
index_stop_learning2 = n_frames_part0 + n_frames_part1+n_frames_part2+n_frames_part0+n_frames_part1;
x_patch_learning1 = [index_start_learning1 index_stop_learning1 index_stop_learning1 index_start_learning1];
x_patch_learning2 = [index_start_learning2 index_stop_learning2 index_stop_learning2 index_start_learning2];

ymin = 460;
ymax = 560;
y_patch_learning_pos = [ymin ymin ymax ymax];


figure;
for channel=1:3
    subplot(2,2,channel);
    hold on;
    plot(motorpos_values,'k-');
    plot(m_values_filtered,'k--')
    xlabel('Frame index');
    ylabel(['Motor ' num2str(index_motor_plot) ' Position']);
%     for i=1:parms.n_m
%      plot(lpdata.motor_position(i,index_start:index_end));
%     end
    yyaxis right;
    %plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,channel),'--');
    plot(sensor_value(:,channel),'r-');
    plot(sensor_value_filtered(:,channel),'r--');    
    plot(sensor_value_filtered_part(:,channel),'b--');    
    ylabel(['Loadcell channel ' num2str(channel) ' value [N]']);
    
end
%%
lim_lc_dot_values = [-50 50];
lim_m_dot = [-100 100];
y_patch_learning_dot = [lim_lc_dot_values(1) lim_lc_dot_values(1) lim_lc_dot_values(2) lim_lc_dot_values(2)];

figure;
for channel=1:3
    subplot(2,2,channel);
    hold on;
    plot(m_dot_values,'b');
    %plot(m_dot_filtered,'g--');
    plot([0;m_values_filtered_dot],'b*-');
    xlabel('Frame index');
    ylabel(['Motor ' num2str(index_motor_plot) ' Speed']);
    ylim(lim_m_dot);
%     for i=1:parms.n_m
%      plot(lpdata.motor_position(i,index_start:index_end));
%     end
    yyaxis right;
    plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,channel),'r-');
    %plot(s_dot_filtered(:,channel),'r--');
    plot([0;sensor_value_dot_filtered(:,channel)],'r-*');
    patch(x_patch_learning1,y_patch_learning_dot,'blue','FaceAlpha',0.1,'EdgeColor','none');
    patch(x_patch_learning2,y_patch_learning_dot,'blue','FaceAlpha',0.1,'EdgeColor','none');
%    legend('Speed','Speed Filtered','Pos filtered then diff','Raw diff signal','Diff signal filtered','filtered then differentiated');
    legend('Speed','Pos filtered then diff','Raw diff signal','filtered then differentiated');

    ylabel(['Loadcell channel ' num2str(channel) ' differentiated value [N/s]']);
    ylim(lim_lc_dot_values);
end
% %%

%%
weights_robotis=read_weights_robotis(recordID,parms);
hinton_LC(weights_robotis{parms.n_twitches},parms);

weights_filtered = compute_weights_wrapper(data,lpdata,parms,1,0,0,0);
hinton_LC(weights_filtered{parms.n_twitches},parms);

weights_check = compute_weights_wrapper(data,lpdata,parms,0,0,0,0);
max_dif_norm = check_weights_diff(weights_check,weights_robotis,5)
