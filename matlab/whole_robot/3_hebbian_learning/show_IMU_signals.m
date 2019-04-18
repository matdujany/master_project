clear; 
close all; clc;

addpath('../2_load_data_code');

%% Load data
recordID = 56;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_robotis = read_weights_robotis(recordID,parms);

twitch_cycle_idx = 1;
n_frames_theo = get_theo_number_frames(parms);

index_start = 1 + n_frames_theo.per_twitch*(twitch_cycle_idx-1);
index_end = n_frames_theo.per_twitch*twitch_cycle_idx;

[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
n_action = (parms.n_m*parms.n_dir);
idx_start_learning = pos_start_learning(1+n_action*(twitch_cycle_idx-1):n_action*twitch_cycle_idx);  
idx_end_learning = pos_end_learning(1+n_action*(twitch_cycle_idx-1):n_action*twitch_cycle_idx);  

%%
hinton_IMU(weights_robotis{parms.n_twitches},parms);


%% acc IMU raw
% figure;
% for i=1:3
% subplot(2,2,i);
% hold on;
% plot(data.float_value_time{1,parms.nr_arduino+1}(index_start:index_end,i));
% plot_patch_learning(gcf(),idx_start_learning,idx_end_learning);
% end
% sgtitle('IMU accelerometer raw signals');

%% acc IMU corrected
figure;
for i=1:3
subplot(2,2,i);
hold on;
% plot(data.IMU_corrected(index_start:index_end,i));
plot(myfilter(data.IMU_corrected(index_start:index_end,i),parms.add_filter_size+2));
ax=gca();
plot_patch_learning(ax.YLim,idx_start_learning,idx_end_learning);
end
sgtitle('IMU accelerometer corrected signals');

%% gyro IMU raw
% figure;
% for i=1:3
% subplot(2,2,i);
% hold on;
% plot(data.float_value_time{1,parms.nr_arduino+1}(index_start:index_end,i+3));
% plot_patch_learning(gcf(),idx_start_learning,idx_end_learning);
% end
% sgtitle('IMU gyroscope raw signals');

%% gyro IMU corrected
figure;
for i=1:3
subplot(2,2,i);
hold on;
% plot(data.IMU_corrected(index_start:index_end,i+3));
plot(myfilter(data.IMU_corrected(index_start:index_end,i+3),parms.add_filter_size+2));
ax=gca();
plot_patch_learning(ax.YLim,idx_start_learning,idx_end_learning);
end
sgtitle('IMU gyroscope corrected signals');

