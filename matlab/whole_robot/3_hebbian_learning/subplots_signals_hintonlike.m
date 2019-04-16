
clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../../tight_subplot');

%%
% TODO : renorm properly the data (especially for IMU, gyro and acc dont
% have the same scale).

%% Load data
recordID = 17;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights = read_weights_robotis(recordID,parms);
weights_pos = read_weights_pos_robotis(recordID,parms);

idx_twitch = 2;

%%
% hinton_pos_2(weights_pos{parms.n_twitches}',parms,0);
% hinton_LC_2(weights{parms.n_twitches}',parms);
% hinton_IMU_2(weights{parms.n_twitches}',parms);
% hinton_full(weights,weights_pos,parms);

%% computing learning signals
data = compute_filtered_signal_data(data,parms);
s_dot_lc = data.s_dot_lc_filtered;
s_IMU = data.s_IMU_filtered;
[m_dot_values,m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,1);

%% 
%all_subplots_loadcells(idx_twitch,s_dot_lc,parms);
%all_subplots_motor_sensors(idx_twitch,m_s_dot_pos,parms);

%all_subplots_IMU(idx_twitch,s_IMU,parms);

%%
amp_acc = 20;
amp_gyro = 15;
all_subplots_Acc_Gyro(idx_twitch,s_IMU(:,1:3),parms,amp_acc,{'Acc. X', 'Acc. Y', 'Acc. Z'});
all_subplots_Acc_Gyro(idx_twitch,s_IMU(:,4:6),parms,amp_gyro,{'Gyro. Roll','Gyro. Pitch','Gyro. Yaw'});


function all_subplots_Acc_Gyro(idx_twitch,s_IMU,parms,amp,txt_list)
FontSize = 14;
lineWidth = 1.4;

y_min = -amp;
y_max = amp;

x_patch_learning = [26 50 50 26];
y_patch_learning = [y_min y_min y_max y_max];
n_frames_theo = get_theo_number_frames(parms);

index_start_twitch = 1+n_frames_theo.per_twitch*(idx_twitch-1);


f=figure;
f.Color = 'w';
% tight_subplot(Nh, Nw, gap, marg_h, marg_w) 
[ha, pos] = tight_subplot(parms.n_m*2,3,[.01 .01],[.01 .03],[.035 .01]);
for i_motor = 1:parms.n_m*2
    for i_sensor_IMU = 1:3
        axes(ha(3*(i_motor-1)+i_sensor_IMU));
        hold on;
        index_start = index_start_twitch+n_frames_theo.per_action*(i_motor-1);
        index_end = index_start + n_frames_theo.per_action-1;
        plot(s_IMU(index_start:index_end,i_sensor_IMU),'LineWidth',lineWidth);
        patch(x_patch_learning,y_patch_learning,'blue','FaceAlpha',0.1,'EdgeColor','none');
        plot([0 n_frames_theo.per_action-1],[0 0]);
        xlim([n_frames_theo.part0-10 n_frames_theo.part0+n_frames_theo.part1+10]);
        ylim([y_min y_max]);
    end    
end

step_y = -pos{1+3}(2)+pos{1}(2);
y_shift = pos{end}(2)+pos{end}(4);
for i_motor = 1:parms.n_m
    y_pos = step_y*2*(i_motor-1)+y_shift;
    annotation('textbox', [0,y_pos, 0, 0], 'string',['M' num2str(parms.n_m+1-i_motor) '+'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
    annotation('textbox', [0,y_pos+step_y, 0, 0], 'string',['M' num2str(parms.n_m+1-i_motor) '-'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
end

step_x = pos{2}(1)-pos{1}(1);
x_shift = pos{1}(1)+pos{1}(3)/2;
y_pos_column_title = 1.0;
for i_sensor = 1:3
    x_pos = step_x*(i_sensor-1)+x_shift;
    annotation('textbox', [x_pos, y_pos_column_title, 0, 0], 'string',txt_list{1,i_sensor},'FontSize',FontSize,'HorizontalAlignment','center','FitBoxToText','on','EdgeColor','none');
end

end

function all_subplots_IMU(idx_twitch,s_IMU,parms)
FontSize = 14;
lineWidth = 1.4;

x_patch_learning = [26 50 50 26];
y_min = -20;
y_max = 20;
y_patch_learning = [y_min y_min y_max y_max];
n_frames_theo = get_theo_number_frames(parms);

index_start_twitch = 1+n_frames_theo.per_twitch*(idx_twitch-1);


f=figure;
f.Color = 'w';
% tight_subplot(Nh, Nw, gap, marg_h, marg_w) 
[ha, pos] = tight_subplot(parms.n_m*2,6,[.01 .01],[.01 .03],[.035 .01]);
for i_motor = 1:parms.n_m*2
    for i_sensor_IMU = 1:6
        axes(ha(6*(i_motor-1)+i_sensor_IMU));
        hold on;
        index_start = index_start_twitch+n_frames_theo.per_action*(i_motor-1);
        index_end = index_start + n_frames_theo.per_action-1;
        plot(s_IMU(index_start:index_end,i_sensor_IMU),'LineWidth',lineWidth);
        patch(x_patch_learning,y_patch_learning,'blue','FaceAlpha',0.1,'EdgeColor','none');
        plot([0 n_frames_theo.per_action-1],[0 0]);
        xlim([n_frames_theo.part0-10 n_frames_theo.part0+n_frames_theo.part1+10]);
        ylim([y_min y_max]);
    end    
end

step_y = -pos{1+6}(2)+pos{1}(2);
y_shift = pos{end}(2)+pos{end}(4);
for i_motor = 1:parms.n_m
    y_pos = step_y*2*(i_motor-1)+y_shift;
    annotation('textbox', [0,y_pos, 0, 0], 'string',['M' num2str(parms.n_m+1-i_motor) '+'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
    annotation('textbox', [0,y_pos+step_y, 0, 0], 'string',['M' num2str(parms.n_m+1-i_motor) '-'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
end

txt_list = {'Acc. X', 'Acc. Y', 'Acc. Z','Roll','Pitch','Yaw'};
step_x = pos{2}(1)-pos{1}(1);
x_shift = pos{1}(1)+pos{1}(3)/2;
y_pos_column_title = 1.0;
for i_sensor = 1:6
    x_pos = step_x*(i_sensor-1)+x_shift;
    annotation('textbox', [x_pos, y_pos_column_title, 0, 0], 'string',txt_list{1,i_sensor},'FontSize',FontSize,'HorizontalAlignment','center','FitBoxToText','on','EdgeColor','none');
end

end

function all_subplots_motor_sensors(idx_twitch,m_s_dot_pos,parms)

FontSize = 14;
lineWidth = 1.4;

x_patch_learning = [26 50 50 26];
y_min = -0.15;
y_max = 0.15;
y_patch_learning = [y_min y_min y_max y_max];
n_frames_theo = get_theo_number_frames(parms);

index_start_twitch = 1+n_frames_theo.per_twitch*(idx_twitch-1);


f=figure;
f.Color = 'w';
% tight_subplot(Nh, Nw, gap, marg_h, marg_w) 
[ha, pos] = tight_subplot(parms.n_m*2,parms.n_m,[.01 .01],[.01 .03],[.035 .01]);
for i_motor = 1:parms.n_m*2
    for i_motor_sensor = 1:parms.n_m
        axes(ha(parms.n_m*(i_motor-1)+i_motor_sensor));
        hold on;
        index_start = index_start_twitch+n_frames_theo.per_action*(i_motor-1);
        index_end = index_start + n_frames_theo.per_action-1;
        plot(m_s_dot_pos(index_start:index_end,i_motor_sensor),'LineWidth',lineWidth);
        patch(x_patch_learning,y_patch_learning,'blue','FaceAlpha',0.1,'EdgeColor','none');
        plot([0 n_frames_theo.per_action-1],[0 0]);
        xlim([n_frames_theo.part0-10 n_frames_theo.part0+n_frames_theo.part1+10]);
        ylim([y_min y_max]);
    end    
end

step_y = -pos{1+parms.n_m}(2)+pos{1}(2);
y_shift = pos{end}(2)+pos{end}(4);
for i_motor = 1:parms.n_m
    y_pos = step_y*2*(i_motor-1)+y_shift;
    annotation('textbox', [0,y_pos, 0, 0], 'string',['M' num2str(parms.n_m+1-i_motor) '+'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
    annotation('textbox', [0,y_pos+step_y, 0, 0], 'string',['M' num2str(parms.n_m+1-i_motor) '-'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
end

step_x = pos{2}(1)-pos{1}(1);
x_shift = pos{1}(1)+pos{1}(3)/2;
y_pos_column_title = 1.0;
for i_sensor = 1:parms.n_m
    x_pos = step_x*(i_sensor-1)+x_shift;
    annotation('textbox', [x_pos, y_pos_column_title, 0, 0], 'string',['M' num2str(i_sensor)],'FontSize',FontSize,'HorizontalAlignment','center','FitBoxToText','on','EdgeColor','none');
end
end

function all_subplots_loadcells(idx_twitch,s_dot_lc,parms)

FontSize = 12;
%fontSizeTicks = 12;
lineWidth = 1.4;

x_patch_learning = [26 50 50 26];
y_min = -30;
y_max = 30;
y_patch_learning = [y_min y_min y_max y_max];
n_frames_theo = get_theo_number_frames(parms);

index_start_twitch = 1+n_frames_theo.per_twitch*(idx_twitch-1);

f=figure;
f.Color = 'w';
% tight_subplot(Nh, Nw, gap, marg_h, marg_w) 
[ha, pos] = tight_subplot(parms.n_m*2,parms.n_lc*3,[.01 .01],[.01 .03],[.025 .01]);
for i_motor = 1:parms.n_m*2
    for i_sensor = 1:parms.n_lc
        for channel = 1:3
            %subplot(parms.n_m*2,parms.n_lc*3,parms.n_lc*3*(i_motor-1)+3*(i_sensor-1)+channel);
            axes(ha(parms.n_lc*3*(i_motor-1)+3*(i_sensor-1)+channel));
            hold on;
            index_start = index_start_twitch+n_frames_theo.per_action*(i_motor-1);
            index_end = index_start + n_frames_theo.per_action-1;
            plot(s_dot_lc(index_start:index_end,channel+3*(i_sensor-1)),'LineWidth',lineWidth);
            patch(x_patch_learning,y_patch_learning,'blue','FaceAlpha',0.1,'EdgeColor','none');
            plot([0 n_frames_theo.per_action-1],[0 0]);
            %yyaxis right;
            %plot(data.float_value_time{1,i_sensor}(index_start:index_end,channel));
            xlim([n_frames_theo.part0-10 n_frames_theo.part0+n_frames_theo.part1+10]);
            ylim([y_min y_max]);
        end
    end
    
end

%%
step_y = -pos{1+3*parms.n_lc}(2)+pos{1}(2);
y_shift = pos{end}(2)+pos{end}(4);
for i_motor = 1:parms.n_m
    y_pos = step_y*2*(i_motor-1)+y_shift;
    annotation('textbox', [0,y_pos, 0, 0], 'string',['M' num2str(parms.n_m+1-i_motor) '+'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
    annotation('textbox', [0,y_pos+step_y, 0, 0], 'string',['M' num2str(parms.n_m+1-i_motor) '-'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
end

step_x = pos{2}(1)-pos{1}(1);
x_shift = pos{1}(1)+pos{1}(3)/2;
y_pos_column_title = 1.0;
for i_sensor = 1:parms.n_lc
    x_pos = step_x*3*(i_sensor-1)+x_shift;
    annotation('textbox', [x_pos, y_pos_column_title, 0, 0], 'string',['Loadcell ' num2str(i_sensor) ' X'],'FontSize',FontSize,'HorizontalAlignment','center','FitBoxToText','on','EdgeColor','none');
    annotation('textbox', [x_pos + step_x, y_pos_column_title, 0, 0], 'string',['Loadcell ' num2str(i_sensor) ' Y'],'FontSize',FontSize,'HorizontalAlignment','center','FitBoxToText','on','EdgeColor','none');
    annotation('textbox', [x_pos + 2*step_x, y_pos_column_title, 0, 0], 'string',['Loadcell ' num2str(i_sensor) ' Z'],'FontSize',FontSize,'HorizontalAlignment','center','FitBoxToText','on','EdgeColor','none');
end

end
