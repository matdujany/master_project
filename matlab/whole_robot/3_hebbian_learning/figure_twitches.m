clear;
close all; clc;

addpath('../2_load_data_code');
addpath('computing_functions');

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

%% Load data
recordID = 110; %15
[data, lpdata, parms] =  load_data_processed(recordID);
all_neutral_pos = read_neutral_pos(recordID,parms.n_m);
weights_robotis = read_weights_robotis(recordID,parms);
speed = compute_integrated_speed(data,lpdata,parms);

idx_twitch = 1;
idx_motor = 1;
idx_other_motor = idx_motor+1;
idx_direction = 1; %1 or 2 (1 means neg direction, 2 means pos direction);
idx_channel = 1;
idx_channel_acc = 2;
idx_channel_gyro = 3;
good_closest_LC = [3;3;4;4;1;1;2;2];
idx_lc = good_closest_LC(idx_motor);

neutral_pos = all_neutral_pos(idx_motor);

txt_channel_lc ={' X',' Y',' Z'};
txt_channel_acc = {'Acc. X', ' Acc. Y', 'Acc. Z'};
txt_channel_gyro = {'Gyro. Roll','Gyro. Pitch','Gyro. Yaw'};

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
x_patch_learning1 = [index_start_learning1 index_stop_learning1 index_stop_learning1 index_start_learning1]*parms.time_interval_twitch/1000;
y_patch_learning_pos = [ymin ymin ymax ymax];
x_patch_learning2 = [index_start_learning2 index_stop_learning2 index_stop_learning2 index_start_learning2]*parms.time_interval_twitch/1000;

%% time signals
time_plot =(0:index_end-index_start)*parms.time_interval_twitch/1000;
motor_pos_plot = pos2deg(lpdata.motor_position(idx_motor,index_start:index_end),neutral_pos);
other_motor_pos_plot = pos2deg(lpdata.motor_position(idx_other_motor,index_start:index_end));

data_lc = data.float_value_time{1,idx_lc}(index_start:index_end,idx_channel);
offset_lc = mean(data_lc(1:n_frames_theo.part0));
data_lc_plot_centered = data_lc-offset_lc;
rescale_lc = 10/max(abs(data_lc));
data_lc_plot_rescaled = data_lc_plot_centered*rescale_lc;

data_acc = data.IMU_corrected(index_start:index_end,idx_channel_acc);
data_gyro = data.IMU_corrected(index_start:index_end,3+idx_channel_gyro);
rescale_acc = 10/max(abs(data_acc));
rescale_gyro = 10/max(abs(data_gyro));
data_acc_rescaled = data_acc*rescale_acc;
data_gyro_rescaled = data_gyro*rescale_gyro;

legend_list_time = {['Motor ' num2str(idx_motor)], ...%['Motor ' num2str(idx_other_motor)],...
    strcat('Loadcell',txt_channel_lc{1,idx_channel}),txt_channel_acc{1,idx_channel_acc},txt_channel_gyro{1,idx_channel_gyro}};

%% learning signals
motor_pos_filtered = myfilter(motor_pos_plot);
data_lc_filtered = myfilter(data_lc);
data_acc_filtered = myfilter(data_acc);
data_gyro_filtered = myfilter(data_gyro);

other_motor_pos_filtered = myfilter(other_motor_pos_plot);

diff_motor_pos_filtered = diff(motor_pos_filtered)./diff(lpdata.motor_timestamp(idx_motor,index_start:index_end));
diff_other_motor_pos_filtered = diff(other_motor_pos_filtered)./diff(lpdata.motor_timestamp(idx_other_motor,index_start:index_end));
diff_data_lc_filtered = 10^3*diff(data_lc_filtered)./diff(data.time(index_start:index_end,idx_lc));

rescale_acc_filtered = 10/max(abs(data_acc_filtered));
data_acc_filtered_rescaled = data_acc_filtered*rescale_acc_filtered;
rescale_gyro_filtered = 10/max(abs(data_gyro_filtered));
data_gyro_filtered_rescaled = data_gyro_filtered*rescale_gyro_filtered;
rescale_diff_lc_filtered = 10/max(abs(diff_data_lc_filtered));
diff_data_lc_filtered_rescaled = diff_data_lc_filtered*rescale_diff_lc_filtered;

data_speed = speed(index_start:index_end,idx_channel_acc);
rescale_speed = 10/max(abs(data_speed));
speed_rescaled = data_speed*rescale_speed;

time_plot_diff = time_plot(2:end);

%% figure learning signals;
speed_min = -0.05;
speed_max = +0.05;
y_patch_learning_speed = [speed_min speed_min speed_max speed_max];

%sprintf(['Loadcell' txt_channel_lc{1,idx_channel} '\nfilt and diff']),...
legend_list_dot_time = {['Motor ' num2str(idx_motor) ' filt and diff'],...
    ...%['Motor ' num2str(idx_other_motor) ' filt and diff'],...
    ['Loadcell' txt_channel_lc{1,idx_channel} ' filt and diff'],...
    strcat('Speed Y, from acc. filt and integrated'),...
    strcat(txt_channel_gyro{1,idx_channel_gyro}, ' filtered')};


%% figure time signals

color_list=lines(5);
f=figure;
if false
    %time signals part
    % subplot(2,1,1);
    hold on;
    plot(time_plot,motor_pos_plot,'Color',color_list(1,:),'LineStyle', '-','LineWidth',lineWidth);
    % plot(time_plot,other_motor_pos_plot,'Color',color_list(2,:),'LineStyle', '--','LineWidth',lineWidth);
    xlabel('Time [s]','FontSize',fontSize);
    ylabel('Position [deg]','FontSize',fontSize);
    %patch(x_patch_learning1,y_patch_learning_pos,'blue','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
    %patch(x_patch_learning2,y_patch_learning_pos,'blue','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
    ylim([-10 10]);
    yyaxis right;
    plot(time_plot,data_lc_plot_rescaled,'Color',color_list(2,:),'LineStyle', '--','LineWidth',lineWidth);
    plot(time_plot,data_acc_rescaled,'Color',color_list(4,:),'LineStyle','--','LineWidth',lineWidth);
    plot(time_plot,data_gyro_rescaled,'Color',color_list(5,:),'LineStyle','--','LineWidth',lineWidth);
    ylabel('Sensor values rescaled','Color','k','FontSize',fontSize);
    title('Raw signals','FontSize',fontSize);
    lgd = legend(legend_list_time);
    lgd.FontSize = fontSize-2;
    lgd.Orientation='vertical';
    lgd.NumColumns = 2;
%     lgd.Location = 'northwest';
    lgd.Position = [0.5049    0.8113    0.2103    0.0922];
    ax = gca;
    ax.FontSize = fontSizeTicks;
    ax.YAxis(2).Color = 'k';
    grid on;
else
    %dot time signals part
    % subplot(2,1,2);
    hold on;
    plot(time_plot_diff,diff_motor_pos_filtered,'Color',color_list(1,:),'LineStyle', '-','LineWidth',lineWidth);
    % plot(time_plot_diff,diff_other_motor_pos_filtered,'Color',color_list(2,:),'LineStyle', '--','LineWidth',lineWidth);
    xlabel('Time [s]','FontSize',fontSize);
    ylabel('Motor speed [deg/ms]','FontSize',fontSize);
    patch(x_patch_learning1,y_patch_learning_speed,'blue','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
    patch(x_patch_learning2,y_patch_learning_speed,'blue','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
    ylim([speed_min speed_max]);
    yyaxis right;
    plot(time_plot_diff,diff_data_lc_filtered_rescaled,'Color',color_list(2,:),'LineStyle', '--','LineWidth',lineWidth);
    plot(time_plot_diff,speed_rescaled(1:end-1),'Color',color_list(4,:),'LineStyle','--','LineWidth',lineWidth);
    plot(time_plot_diff,data_gyro_filtered_rescaled(2:end),'Color',color_list(5,:),'LineStyle','--','LineWidth',lineWidth);
    ylabel('sensor values rescaled','Color','k','FontSize',fontSize);
    title('Learning signals','FontSize',fontSize);
    ylim([-10 10]);
    lgd = legend(legend_list_dot_time);
    lgd.FontSize = fontSize-2;
    %lgd.Position = [0.68,0.7071,0.189,0.202];
    lgd.Orientation='vertical';
    lgd.NumColumns = 2;
%     lgd.Location = 'north';
    lgd.Position = [0.4548    0.8161    0.4323    0.0922];
    ax = gca;
    ax.FontSize = fontSizeTicks;
    ax.YAxis(2).Color = 'k';
    grid on;
end
% %
% handle_plots = get(ax, 'Children');
% neworder = [1 2 4 5 3];
% legend(hplots(neworder), labels(neworder));

f.Color = 'w';

addpath('../../export_fig');

set(f,'PaperPositionMode','auto');
set(f,'PaperOrientation','landscape');
set(f,'Position',[10 10 1200 500]);
% print(f, '-dpdf', 'figures_report/figure_twitch_raw_105.pdf');
%print(f, '-dpdf', 'figures_report/figure_twitch_learning_105.pdf');

%%
%hinton_LC(weights_robotis{5},parms);

%%
function pos_deg = pos2deg(position,neutral_pos)
conversion_factor = 3.413;
if nargin == 1
    neutral_pos = 512;
end
pos_deg = (position-neutral_pos)/conversion_factor;
end