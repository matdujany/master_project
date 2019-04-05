clear; 
close all; clc;

fontSize = 16;
fontSizeTicks = 13;
lineWidth = 1.4;

%% Load data
addpath('../2_load_data_code');
recordID = 15;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;

weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis = read_weights_pos_robotis(recordID,parms);

idx_motor_picked = 3;
idx_other_motor = 4; %should be same limb
idx_direction = 1; %1 or 2

n_iter = 5;

good_closest_LC = [3;3;4;4;1;1;2;2];
idx_lc = good_closest_LC(idx_motor_picked);
idx_motor_action_picked = 2*(idx_motor_picked-1)+idx_direction;

weights_pos_plot=zeros(1+parms.n_twitches,2);
weights_lc_plot=zeros(1+parms.n_twitches,3);
weights_acc_plot=zeros(1+parms.n_twitches,3);
weights_gyro_plot=zeros(1+parms.n_twitches,3);

for k=1:parms.n_twitches
    weights_pos_plot(1+k,1) = weights_pos_robotis{k}(idx_motor_picked,idx_motor_action_picked);
    weights_pos_plot(1+k,2) = weights_pos_robotis{k}(idx_other_motor,idx_motor_action_picked);
    for i_channel=1:3
        weights_lc_plot(1+k,i_channel)=weights_robotis{k}(3*(idx_lc-1)+i_channel,idx_motor_action_picked);
        weights_acc_plot(1+k,i_channel)=weights_robotis{k}(3*(parms.nr_arduino)+i_channel,idx_motor_action_picked);
        weights_gyro_plot(1+k,i_channel)=weights_robotis{k}(3*(parms.nr_arduino)+3+i_channel,idx_motor_action_picked);
    end
end

renorm_pos = max(max(abs(weights_pos_robotis{5})));
renorm_lc = max(max(abs(weights_robotis{5}(1:3*(parms.nr_arduino),:))));
renorm_imu = max(max(abs(weights_robotis{5}(3*(parms.nr_arduino)+1:3*(parms.nr_arduino)+3,:))));
renorm_gyro = max(max(abs(weights_robotis{5}(3*(parms.nr_arduino)+4:3*(parms.nr_arduino)+6,:))));

weights_pos_plot = weights_pos_plot/renorm_pos;
weights_lc_plot = weights_lc_plot/renorm_lc;
weights_acc_plot = weights_acc_plot/renorm_imu;
weights_gyro_plot = weights_gyro_plot/renorm_gyro;

ylims = [-1 1];

%%
f=figure;
subplot(1,4,1);
hold on;
plot([0:parms.n_twitches],weights_pos_plot(:,1),'LineStyle', '-','LineWidth',lineWidth);
plot([0:parms.n_twitches],weights_pos_plot(:,2),'LineStyle', '-','LineWidth',lineWidth);
ylabel('Weight Value','FontSize',fontSize);
plot_layout(parms,fontSize,fontSizeTicks,ylims,{'Motor 1','Motor 2'},'Motor Positions')

%%
subplot(1,4,2);
hold on;
legend_list = {'X','Y','Z'};
for i_channel=1:3
    plot([0:parms.n_twitches],weights_lc_plot(:,i_channel),'LineStyle', '-','LineWidth',lineWidth);
end
plot_layout(parms,fontSize,fontSizeTicks,ylims,legend_list,'Loadcell')

%%
subplot(1,4,3);
hold on;
legend_list = {'X','Y','Z'};
for i_channel=1:3
    plot([0:parms.n_twitches],weights_acc_plot(:,i_channel),'LineStyle', '-','LineWidth',lineWidth);
end
plot_layout(parms,fontSize,fontSizeTicks,ylims,legend_list,'Accelerometer')

%%
subplot(1,4,4);
hold on;
legend_list = {'Gyro. Roll','Gyro. Pitch','Gyro. Yaw'};
for i_channel=1:3
    plot([0:parms.n_twitches],weights_gyro_plot(:,i_channel),'LineStyle', '-','LineWidth',lineWidth);
end
plot_layout(parms,fontSize,fontSizeTicks,ylims,legend_list,'Gyroscope')

%%
f.Color = 'w';
addpath('../../export_fig');
set(f,'Position',[10 10 1900 400]);
set(f,'PaperOrientation','landscape');
export_fig 'figures_simon/weights_convergence.pdf'



function plot_layout(parms,fontSize,fontSizeTicks,ylims,legend_list,titleString)
xlabel('Twitch iteration','FontSize',fontSize);
xticks([0:parms.n_twitches]);
lgd=legend(legend_list);
lgd.FontSize = fontSize;
title(titleString,'FontSize',fontSize);
ax = gca;
ax.FontSize = fontSizeTicks;
grid on;
ylim(ylims);
end