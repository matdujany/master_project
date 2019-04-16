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

idx_motor_picked = 1;
idx_other_motor = 2; %should be same limb
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

ylims = [-1.2 1.2];

transpose = false;
%%
f=figure;
if transpose
    ah{1}=subplot(4,1,1);
else
    ah{1}=subplot(1,4,1); 
end
hold on;
plot([0:parms.n_twitches],weights_pos_plot(:,1),'LineStyle', '-','LineWidth',lineWidth);
plot([0:parms.n_twitches],weights_pos_plot(:,2),'LineStyle', '-','LineWidth',lineWidth);
plot_layout(parms,fontSize,fontSizeTicks,ylims,{'M1','M2'},'Motor Positions')
if ~transpose
    ylabel('Weight Value','FontSize',fontSize);
end

%%
if transpose
    ah{2}=subplot(4,1,2);
else
    ah{2}=subplot(1,4,2); 
end
hold on;
legend_list = {'X','Y','Z'};
for i_channel=1:3
    plot([0:parms.n_twitches],weights_lc_plot(:,i_channel),'LineStyle', '-','LineWidth',lineWidth);
end
plot_layout(parms,fontSize,fontSizeTicks,ylims,legend_list,'Loadcell')

%%
if transpose
    ah{3}=subplot(4,1,3);
else
    ah{3}=subplot(1,4,3); 
end
hold on;
legend_list = {'X','Y','Z'};
for i_channel=1:3
    plot([0:parms.n_twitches],weights_acc_plot(:,i_channel),'LineStyle', '-','LineWidth',lineWidth);
end
plot_layout(parms,fontSize,fontSizeTicks,ylims,legend_list,'Accelerometer')

%%
if transpose
    ah{4}=subplot(4,1,4);
else
    ah{4}=subplot(1,4,4); 
end
hold on;
legend_list = {'Roll','Pitch','Yaw'};
for i_channel=1:3
    plot([0:parms.n_twitches],weights_gyro_plot(:,i_channel),'LineStyle', '-','LineWidth',lineWidth);
end
plot_layout(parms,fontSize,fontSizeTicks,ylims,legend_list,'Gyroscope')
if transpose
    xlabel('Twitch iteration','FontSize',fontSize);
end

if transpose
%# find current position [x,y,width,height]
for i=1:4
    pos{i} = get(ah{i},'Position');
end

%# set width of second axes equal to first
for i=1:3
    pos{i}(3)=pos{4}(3);
end
for i=1:3
    set(ah{i},'Position',pos{i})
end
end

%%
f.Color = 'w';
addpath('../../export_fig');
if transpose
set(f,'Position',[10 10 550 900]);
else
    set(f,'Position',[10 10 1800 300]);
end
%set(f,'PaperOrientation','landscape');
% export_fig 'figures_simon/weights_convergence.pdf'



function plot_layout(parms,fontSize,fontSizeTicks,ylims,legend_list,titleString)
transpose = false;
xticks([0:parms.n_twitches]);
lgd=legend(legend_list);
if transpose
    lgd.Location='eastoutside';
else
    lgd.Location='best';    
end
%lgd.Position = [0.670634920634921,0.146500001072884,0.221428568448339,0.076999997854233];
lgd.FontSize = fontSize-3;
%lgd.NumColumns = 3;
title(titleString,'FontSize',fontSize);
ax = gca;
ax.FontSize = fontSizeTicks;
grid on;
ylim(ylims);
if transpose
    ylabel('Weight Value','FontSize',fontSize);
else
    xlabel('Twitch iteration','FontSize',fontSize);
end   
end