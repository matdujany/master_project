clear; 
close all; clc;

addpath('../data');

%% Load data
recordID = 73;
load(strcat(get_record_name(recordID),'_p'));
add_parms;

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

flagFilter = 0;
[m_dot_learning,m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,flagFilter);

figure;
for channel=1:3
    subplot(2,2,channel);
    hold on;
    plot(lpdata.motor_position(index_motor_plot,index_start:index_end));
    xlabel('Frame index');
    ylabel(['Motor ' num2str(index_motor_plot) ' Position']);
%     for i=1:parms.n_m
%      plot(lpdata.motor_position(i,index_start:index_end));
%     end
    yyaxis right;
    %plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,channel),'--');
    plot(data.float_value_time{1,index_loadcell_plot}(index_start:index_end,channel),'--');
    ylabel(['Loadcell channel ' num2str(channel) ' value [N]']);
    
end

figure;
for channel=1:3
    subplot(2,2,channel);
    hold on;
    plot(lpdata.motor_position(index_motor_plot,index_start:index_end));
    xlabel('Frame index');
    ylabel(['Motor ' num2str(index_motor_plot) ' Position']);
%     for i=1:parms.n_m
%      plot(lpdata.motor_position(i,index_start:index_end));
%     end
    yyaxis right;
    plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,channel),'--');
    ylabel(['Loadcell channel ' num2str(channel) ' differentiated value [N/s]']);
    ylim([-100 100]);
end

weights=read_weights_robotis(recordID,parms);
hinton_LC(weights{parms.n_twitches},parms);

%%
fontSize = 16;
fontSizeTicks = 13;
lineWidth = 1.4;

sampling_freq = 10^3/36;

index_start_learning1 = n_frames_part0+1;
index_stop_learning1 = n_frames_part0 + n_frames_part1;
index_start_learning2 = n_frames_part0 + n_frames_part1+n_frames_part2+n_frames_part0+1;
index_stop_learning2 = n_frames_part0 + n_frames_part1+n_frames_part2+n_frames_part0+n_frames_part1;
n_frames = index_end-index_start+1;

ymin = -8;
ymax = 8;
speed_min = -40;
speed_max = +40;
x_patch_learning1 = [index_start_learning1 index_stop_learning1 index_stop_learning1 index_start_learning1]/sampling_freq;
y_patch_learning_pos = [ymin ymin ymax ymax];
x_patch_learning2 = [index_start_learning2 index_stop_learning2 index_stop_learning2 index_start_learning2]/sampling_freq;
y_patch_learning_speed = [speed_min speed_min speed_max speed_max];

motor_pos_plot = pos2deg(lpdata.motor_position(index_motor_plot,index_start:index_end));
offset = mean(motor_pos_plot);
motor_pos_plot = motor_pos_plot-offset;

conversion_factor = 3.413;
m_dot_plot = 10^3*m_dot_learning(index_start:index_end)/conversion_factor;
time = [1:n_frames]/sampling_freq;

figure
%subplot(2,1,1);
hold on;
grid on;
plot(time,motor_pos_plot,'LineWidth',lineWidth);
plot([index_start_learning1 index_start_learning1]/sampling_freq, [ymin ymax],'b--','LineWidth',lineWidth);
plot([index_stop_learning1 index_stop_learning1]/sampling_freq, [ymin ymax],'b--','LineWidth',lineWidth);
plot([index_start_learning2 index_start_learning2]/sampling_freq, [ymin ymax],'b--','LineWidth',lineWidth);
plot([index_stop_learning2 index_stop_learning2]/sampling_freq, [ymin ymax],'b--','LineWidth',lineWidth);


%patch(x_patch_learning1,y_patch_learning_pos,'blue','FaceAlpha',0.1,'EdgeColor','none');
%patch(x_patch_learning2,y_patch_learning_pos,'blue','FaceAlpha',0.1,'EdgeColor','none');
ylim([ymin ymax]);
xlabel('Time [s]','FontSize',fontSize);
ylabel('Position [deg]','FontSize',fontSize);
yyaxis right;
plot(time,data.float_value_time{1,index_loadcell_plot}(index_start:index_end,3),'--','LineWidth',lineWidth);
%ylabel({'Loadcell value [N]','(channel Z)'},'FontSize',fontSize);
ylim([2 8]);
ylabel('Force [N]','FontSize',fontSize);
ax = gca;
ax.FontSize = fontSizeTicks; 
hold off;
%export_fig motorpos_loadcellvalue.png
%print(gcf, '-dpdf', 'motorpos_loadcellvalue.pdf'); 
 
figure
%subplot(2,1,2);
hold on;
grid on;
plot(time,(m_dot_plot),'LineWidth',lineWidth);
patch(x_patch_learning1,y_patch_learning_speed,'blue','FaceAlpha',0.1,'EdgeColor','none');
patch(x_patch_learning2,y_patch_learning_speed,'blue','FaceAlpha',0.1,'EdgeColor','none');
ylim([speed_min speed_max]);
xlabel('Time [s]','FontSize',fontSize);
ylabel('Speed [deg/s]','FontSize',fontSize);
yyaxis right;
plot(time,(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,3)),'--','LineWidth',lineWidth);
plot([time(1) time(end)],[0 0],'k--');
%ylabel({'Loadcell channel Z';'differentiated value [N/s]'},'FontSize',15);
ylabel('Differentiated Force [N/s]','FontSize',14);
ylim([-50 50]);
ax = gca;
ax.FontSize = fontSizeTicks; 
hold off;

%%
hinton_LC(weights{5},parms)

%%
weights_part = weights{parms.n_twitches}(1+3*(index_loadcell_plot-1):3*index_loadcell_plot,1+2*(index_motor_plot-1):2*(index_motor_plot+1));
%weights_part
[h,fig_parms] = hinton(weights_part,'Loadcell channels');
hold on;
plot([2 2],[fig_parms.ymin fig_parms.ymax],'k--');
hold off;
export_fig corr_mat2.pdf
%%
% [lpdata,data,idx_start,idx_end] = compute_avg_cycles(lpdata,data,parms);
% 
% index_start_avg = 1+ (n_frames_part0+n_frames_part1+n_frames_part2)*(index_motor_plot-1)*parms.n_dir;
% index_end_avg = (n_frames_part0+n_frames_part1+n_frames_part2)*(index_motor_plot)*parms.n_dir;
% 
% motor_avg_pos = pos2deg(lpdata.motor_position_avg(index_motor_plot,index_start_avg:index_end_avg));
% data_lc_avg = data.float_value_time_avg{index_loadcell_plot}(index_start_avg:index_end_avg,3);
% 
% figure
% %subplot(2,1,1);
% hold on;
% grid on;
% plot(time,motor_avg_pos,'*');
% patch(x_patch_learning1,y_patch_learning_pos,'blue','FaceAlpha',0.1,'EdgeColor','none');
% patch(x_patch_learning2,y_patch_learning_pos,'blue','FaceAlpha',0.1,'EdgeColor','none');
% ylim([ymin ymax]);
% xlabel('Time [s]','FontSize',fontSize);
% ylabel('Position [deg]','FontSize',fontSize);
% yyaxis right;
% plot(time,data_lc_avg,'--','LineWidth',lineWidth);
% %ylabel({'Loadcell value [N]','(channel Z)'},'FontSize',fontSize);
% ylabel('Force [N]','FontSize',fontSize);
% ax = gca;
% ax.FontSize = fontSizeTicks; 
% hold off;
% %export_fig motorpos_loadcellvalue.png
% %print(gcf, '-dpdf', 'motorpos_loadcellvalue.pdf'); 
%  
% m_dot_avg = lpdata.m_dot_values_avg(index_start_avg:index_end_avg);
% data_lc_dot_avg = data.float_value_dot_time_avg{index_loadcell_plot}(index_start_avg:index_end_avg,3);
% 
% figure
% %subplot(2,1,2);
% hold on;
% grid on;
% plot(time,m_dot_avg,'LineWidth',lineWidth);
% patch(x_patch_learning1,y_patch_learning_speed,'blue','FaceAlpha',0.1,'EdgeColor','none');
% patch(x_patch_learning2,y_patch_learning_speed,'blue','FaceAlpha',0.1,'EdgeColor','none');
% ylim([speed_min speed_max]);
% xlabel('Time [s]','FontSize',fontSize);
% ylabel('Speed [deg/s]','FontSize',fontSize);
% yyaxis right;
% plot(time,data_lc_dot_avg,'--','LineWidth',lineWidth);
% plot([time(1) time(end)],[0 0],'k--');
% %ylabel({'Loadcell channel Z';'differentiated value [N/s]'},'FontSize',15);
% ylabel('Differentiated Force [N/s]','FontSize',14);
% ylim([-70 70]);
% ax = gca;
% ax.FontSize = fontSizeTicks; 
% hold off;
%%
function pos_deg = pos2deg(position)
conversion_factor = 3.413;
pos_deg = (position-512)/conversion_factor;
end
