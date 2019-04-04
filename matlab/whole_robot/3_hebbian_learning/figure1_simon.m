clear; 
close all; clc;

addpath('../2_load_data_code');

fontSize = 16;
fontSizeTicks = 13;
lineWidth = 1.4;

%% Load data
recordID = 15;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_robotis = read_weights_robotis(recordID,parms);

idx_twitch = 2;
idx_motor = 5;
idx_other_motor = idx_motor+1;
idx_direction = 1; %1 or 2 (1 means neg direction, 2 means pos direction);
idx_channel = 3;
idx_channel_IMU = 4;
good_closest_LC = [3;3;4;4;1;1;2;2];
idx_lc = good_closest_LC(idx_motor);

n_frames_theo = get_theo_number_frames(parms);
index_start = 1+n_frames_theo.per_twitch*(idx_twitch-1) + n_frames_theo.per_action*(idx_motor-1)*parms.n_dir;
index_end = n_frames_theo.per_twitch*(idx_twitch-1)  + n_frames_theo.per_action*idx_motor*parms.n_dir;

%%
index_start_learning1 = n_frames_theo.part0+1;
index_stop_learning1 = n_frames_theo.part0 + n_frames_theo.part1;
index_start_learning2 = n_frames_theo.per_action+n_frames_theo.part0+1;
index_stop_learning2 = n_frames_theo.per_action+ n_frames_theo.part0 + n_frames_theo.part1;
n_frames = index_end-index_start+1;

ymin = -8;
ymax = 8;
x_patch_learning1 = [index_start_learning1 index_stop_learning1 index_stop_learning1 index_start_learning1]*parms.time_interval_twitch;
y_patch_learning_pos = [ymin ymin ymax ymax];
x_patch_learning2 = [index_start_learning2 index_stop_learning2 index_stop_learning2 index_start_learning2]*parms.time_interval_twitch;

%% time signals
time_plot =(0:index_end-index_start)*parms.time_interval_twitch;
motor_pos_plot = pos2deg(lpdata.motor_position(idx_motor,index_start:index_end));
other_motor_pos_plot = pos2deg(lpdata.motor_position(idx_other_motor,index_start:index_end));

data_lc = data.float_value_time{1,idx_lc}(index_start:index_end,idx_channel);
offset_lc = mean(data_lc(1:n_frames_theo.part0));
data_lc_plot_centered = data_lc-offset_lc;
rescale_lc = 10/max(abs(data_lc_plot_centered));
data_lc_plot_rescaled = data_lc_plot_centered*rescale_lc;

data_IMU = data.IMU_corrected(index_start:index_end,idx_channel_IMU);
rescale_IMU = 10/max(abs(data_IMU));
offset_IMU = mean(data_IMU(1:n_frames_theo.part0));
data_IMU_plot_rescaled = data_IMU*rescale_IMU;

legend_list = {['Motor ' num2str(idx_motor)], ['Motor ' num2str(idx_other_motor)],...
               ['Loadcell ' num2str(idx_lc) ' channel ' num2str(idx_channel)],...
               ['IMU channel ' num2str(idx_channel_IMU)]};

%% figure time signals
color_list=lines(4);
figure;
hold on;
plot(time_plot,motor_pos_plot,'Color',color_list(1,:),'LineStyle', '-','LineWidth',lineWidth);
plot(time_plot,other_motor_pos_plot,'Color',color_list(2,:),'LineStyle', '--','LineWidth',lineWidth);
xlabel('Time [s]','FontSize',fontSize);
ylabel('Position [deg]','FontSize',fontSize);
patch(x_patch_learning1,y_patch_learning_pos,'blue','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
patch(x_patch_learning2,y_patch_learning_pos,'blue','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
yyaxis right;
plot(time_plot,data_lc_plot_rescaled,'Color',color_list(3,:),'LineStyle', '--','LineWidth',lineWidth);
plot(time_plot,data_IMU_plot_rescaled,'Color',color_list(4,:),'LineStyle','--','LineWidth',lineWidth);
ylabel('Sensor values rescaled','Color','k','FontSize',fontSize);
lgd = legend(legend_list);
lgd.FontSize = fontSize;
ax = gca;
ax.FontSize = fontSizeTicks;
ax.YAxis(2).Color = 'k';


%% learning signals
motor_pos_filtered = myfilter(motor_pos_plot);
data_lc_filtered = myfilter(data_lc);
data_IMU_filtered = myfilter(data_IMU);
other_motor_pos_filtered = myfilter(other_motor_pos_plot);

diff_motor_pos_filtered = diff(motor_pos_filtered)./diff(lpdata.motor_timestamp(idx_motor,index_start:index_end));
diff_other_motor_pos_filtered = diff(other_motor_pos_filtered)./diff(lpdata.motor_timestamp(idx_other_motor,index_start:index_end));
diff_data_lc_filtered = 10^3*diff(data_lc_filtered)./diff(data.time(index_start:index_end,idx_lc));

rescale_IMU_filtered = 10/max(abs(data_IMU_filtered));
data_IMU_filtered_rescaled = data_IMU_filtered*rescale_IMU_filtered;
rescale_diff_lc_filtered = 10/max(abs(diff_data_lc_filtered));
diff_data_lc_filtered_rescaled = diff_data_lc_filtered*rescale_diff_lc_filtered;

time_plot_diff = time_plot(2:end);

%% figure learning signals;
speed_min = -0.05;
speed_max = +0.05;
y_patch_learning_speed = [speed_min speed_min speed_max speed_max];

legend_list = {['Motor ' num2str(idx_motor) ' filtered and differentiated'],...
                ['Motor ' num2str(idx_other_motor) ' filtered and differentiated'],...
               ['Loadcell ' num2str(idx_lc) ' channel ' num2str(idx_channel) ' filtered and differentiated'],...
               ['IMU channel ' num2str(idx_channel_IMU) ' filtered']};

figure;
hold on;
plot(time_plot_diff,diff_motor_pos_filtered,'Color',color_list(1,:),'LineStyle', '-','LineWidth',lineWidth);
plot(time_plot_diff,diff_other_motor_pos_filtered,'Color',color_list(2,:),'LineStyle', '--','LineWidth',lineWidth);
xlabel('Time [s]','FontSize',fontSize);
ylabel('Speed [deg/ms]','FontSize',fontSize);
patch(x_patch_learning1,y_patch_learning_speed,'blue','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
patch(x_patch_learning2,y_patch_learning_speed,'blue','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
ylim([speed_min speed_max]);
yyaxis right;
plot(time_plot_diff,diff_data_lc_filtered_rescaled,'Color',color_list(3,:),'LineStyle', '--','LineWidth',lineWidth);
plot(time_plot_diff,data_IMU_filtered_rescaled(2:end),'Color',color_list(4,:),'LineStyle','--','LineWidth',lineWidth);
ylabel('sensor values (rescaled)','Color','k','FontSize',fontSize);
ylim([-10 10]);
lgd = legend(legend_list);
lgd.FontSize = fontSize;
ax = gca;
ax.FontSize = fontSizeTicks;
ax.YAxis(2).Color = 'k';

%%
hinton_LC(weights_robotis{5},parms);

%%
function pos_deg = pos2deg(position)
conversion_factor = 3.413;
pos_deg = (position-512)/conversion_factor;
end