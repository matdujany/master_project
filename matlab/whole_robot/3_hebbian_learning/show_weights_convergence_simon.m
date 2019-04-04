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

%%
figure;
hold on;
plot([0:parms.n_twitches],weights_pos_plot(:,1),'LineStyle', '-','LineWidth',lineWidth);
plot([0:parms.n_twitches],weights_pos_plot(:,2),'LineStyle', '-','LineWidth',lineWidth);
xlabel('Twitch iteration','FontSize',fontSize);
xticks([0:parms.n_twitches]);
lgd=legend({'Motor 1','Motor 2'});
lgd.FontSize = fontSize;
title('Motor Sensor','FontSize',fontSize);

%%
figure;
hold on;
for i_channel=1:3
    plot([0:parms.n_twitches],weights_lc_plot(:,i_channel),'LineStyle', '-','LineWidth',lineWidth);
    legend_list{i_channel,1} = ['Channel ' num2str(i_channel)];
end
xlabel('Twitch iteration','FontSize',fontSize);
xticks([0:parms.n_twitches]);
lgd=legend(legend_list);
lgd.FontSize = fontSize;
title('Loadcell','FontSize',fontSize);

%%
figure;
hold on;
for i_channel=1:3
    plot([0:parms.n_twitches],weights_acc_plot(:,i_channel),'LineStyle', '-','LineWidth',lineWidth);
    legend_list{i_channel,1} = ['Channel ' num2str(i_channel)];
end
xlabel('Twitch iteration','FontSize',fontSize);
xticks([0:parms.n_twitches]);
lgd=legend(legend_list);
lgd.FontSize = fontSize;
title('Accelerometer','FontSize',fontSize);


%%
figure;
hold on;
for i_channel=1:3
    plot([0:parms.n_twitches],weights_gyro_plot(:,i_channel),'LineStyle', '-','LineWidth',lineWidth);
    legend_list{i_channel,1} = ['Channel ' num2str(i_channel)];
end
xlabel('Twitch iteration','FontSize',fontSize);
xticks([0:parms.n_twitches]);
lgd=legend(legend_list);
lgd.FontSize = fontSize;
title('Gyroscope','FontSize',fontSize);