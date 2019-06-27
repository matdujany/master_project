
clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../../tight_subplot');


%% Load data
recordID = 62;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
parms.n_useful_ch_IMU=4;
weights = read_weights_robotis(recordID,parms);
weights_pos = read_weights_pos_robotis(recordID,parms);

idx_twitch = 1;

%%
weights_lc = weights{5}(1:parms.n_lc*3,:);
for i=1:parms.n_m*2
    weights_lc_flipped(:,i)=weights_lc(:,i)*(-1)^(i);
end

hinton_LC(weights_lc_flipped,parms,1);

%%
% hinton_pos_2(weights_pos{parms.n_twitches}',parms,0);
% hinton_LC_2(weights{parms.n_twitches}',parms);
% hinton_IMU_2(weights{parms.n_twitches}',parms);
% hinton_full(weights,weights_pos,parms);

%% computing learning signals
data = compute_filtered_signal_data(data,parms);
s_dot_lc = data.s_dot_lc_filtered;
s_IMU = data.s_IMU_filtered;

FontSize = 12;
%fontSizeTicks = 12;
lineWidth = 1.4;

n_frames_theo = get_theo_number_frames(parms)
x_patch_learning = [n_frames_theo.part0+1 n_frames_theo.part0+n_frames_theo.part1 n_frames_theo.part0+n_frames_theo.part1 n_frames_theo.part0+1];
y_min = -10;
y_max = 10;
y_patch_learning = [y_min y_min y_max y_max];

index_start_twitch = 1+n_frames_theo.per_twitch*(idx_twitch-1);


f=figure;
f.Color = 'w';
% tight_subplot(Nh, Nw, gap, marg_h, marg_w) 
[ha, pos] = tight_subplot(parms.n_lc,parms.n_m*2,[.01 .01],[.01 .03],[.025 .01]);
for i_sensor = 1:parms.n_lc
    for i_motor = 1:parms.n_m*2
        %subplot(parms.n_m*2,parms.n_lc*3,parms.n_lc*3*(i_motor-1)+3*(i_sensor-1)+channel);
        axes(ha(parms.n_m*2*(i_sensor-1)+i_motor));
        hold on;
        index_start = index_start_twitch+n_frames_theo.per_action*(i_motor-1);
        index_end = index_start + n_frames_theo.per_action-1;
        plot(data.float_value_time{1,i_sensor}(index_start:index_end,3),'LineWidth',lineWidth);
        ylim([-2 10]);
        %plot(s_dot_lc(index_start:index_end,3*i_sensor),'LineWidth',lineWidth);
        %ylim([y_min y_max]);
        patch(x_patch_learning,y_patch_learning,'blue','FaceAlpha',0.1,'EdgeColor','none');
        plot([0 n_frames_theo.per_action-1],[0 0]);
        %yyaxis right;
        %plot(lpdata.motor_position(ceil(i_motor/2),index_start:index_end));
        %xlim([n_frames_theo.part0-10 n_frames_theo.part0+n_frames_theo.part1+10]);
    end
end

%%
step_y = -pos{1+2*parms.n_m}(2)+pos{1}(2);
y_shift = pos{end}(2)+pos{end}(4)/2;
for i_sensor = 1:parms.n_lc
    y_pos = step_y*(i_sensor-1)+y_shift;
    annotation('textbox', [0,y_pos, 0, 0], 'string',['Loadcell ' num2str(parms.n_lc+1-i_sensor) ' Z'],'FontSize',FontSize,'HorizontalAlignment','center','FitBoxToText','on','EdgeColor','none');
end

step_x = pos{2}(1)-pos{1}(1);
x_shift = pos{1}(1)+pos{1}(3)/2;
y_pos_column_title = 1.0;
for i_motor = 1:parms.n_m
    x_pos = step_x*2*(i_motor-1)+x_shift;
    annotation('textbox', [x_pos, y_pos_column_title, 0, 0], 'string',['M' num2str(i_motor) '-'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
    annotation('textbox', [x_pos+step_x, y_pos_column_title, 0, 0], 'string',['M' num2str(i_motor) '+'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
end


% f=figure;
% f.Color = 'w';
% % tight_subplot(Nh, Nw, gap, marg_h, marg_w) 
% [ha, pos] = tight_subplot(parms.n_m*2,parms.n_lc,[.01 .01],[.01 .03],[.025 .01]);
% for i_motor = 1:parms.n_m*2
%     for i_sensor = 1:parms.n_lc
%         %subplot(parms.n_m*2,parms.n_lc*3,parms.n_lc*3*(i_motor-1)+3*(i_sensor-1)+channel);
%         axes(ha(parms.n_lc*(i_motor-1)+i_sensor));
%         hold on;
%         index_start = index_start_twitch+n_frames_theo.per_action*(i_motor-1);
%         index_end = index_start + n_frames_theo.per_action-1;
%         plot(data.float_value_time{1,i_sensor}(index_start:index_end,3),'LineWidth',lineWidth);
%         ylim([-2 10]);
%         %plot(s_dot_lc(index_start:index_end,3*i_sensor),'LineWidth',lineWidth);
%         ylim([y_min y_max]);
%         patch(x_patch_learning,y_patch_learning,'blue','FaceAlpha',0.1,'EdgeColor','none');
%         plot([0 n_frames_theo.per_action-1],[0 0]);
%         %yyaxis right;
%         %plot(lpdata.motor_position(ceil(i_motor/2),index_start:index_end));
%         xlim([n_frames_theo.part0-10 n_frames_theo.part0+n_frames_theo.part1+10]);
%     end
% end
% 
% %%
% step_y = -pos{1+parms.n_lc}(2)+pos{1}(2);
% y_shift = pos{end}(2)+pos{end}(4);
% for i_motor = 1:parms.n_m
%     y_pos = step_y*2*(i_motor-1)+y_shift;
%     annotation('textbox', [0,y_pos, 0, 0], 'string',['M' num2str(parms.n_m+1-i_motor) '+'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
%     annotation('textbox', [0,y_pos+step_y, 0, 0], 'string',['M' num2str(parms.n_m+1-i_motor) '-'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
% end
% 
% step_x = pos{2}(1)-pos{1}(1);
% x_shift = pos{1}(1)+pos{1}(3)/2;
% y_pos_column_title = 1.0;
% for i_sensor = 1:parms.n_lc
%     x_pos = step_x*(i_sensor-1)+x_shift;
%     annotation('textbox', [x_pos, y_pos_column_title, 0, 0], 'string',['Loadcell ' num2str(i_sensor) ' Z'],'FontSize',FontSize,'HorizontalAlignment','center','FitBoxToText','on','EdgeColor','none');
% end