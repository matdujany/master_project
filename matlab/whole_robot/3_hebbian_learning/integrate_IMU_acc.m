clear; 
close all; clc;

addpath('../2_load_data_code');

%% Load data
recordID = 14;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_robotis = read_weights_robotis(recordID,parms);
weights_pos_robotis = read_weights_pos_robotis(recordID,parms);

%%
%hinton_LC_2(weights_robotis{parms.n_twitches}',parms,0);
hinton_IMU(weights_robotis{parms.n_twitches},parms);
%%
%hinton_pos_2(weights_pos_robotis{parms.n_twitches}',parms,0);
%%
%hinton_full(weights_robotis,weights_pos_robotis,parms);
%%

twitch_cycle_idx = 1;
n_frames_theo = get_theo_number_frames(parms);

index_start = 1 + n_frames_theo.per_twitch*(twitch_cycle_idx-1);
index_end = n_frames_theo.per_twitch*twitch_cycle_idx;

[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
n_action = (parms.n_m*parms.n_dir);
idx_start_learning = pos_start_learning(1+n_action*(twitch_cycle_idx-1):n_action*twitch_cycle_idx);  
idx_end_learning = pos_end_learning(1+n_action*(twitch_cycle_idx-1):n_action*twitch_cycle_idx);  

%%
integrated_speed = zeros(size(data.IMU_corrected,1),3);
integrated_speed_2 = zeros(size(data.IMU_corrected,1),3);

data_IMU_filtered = myfilter(data.IMU_corrected);
for i=1:length(pos_start_learning)
    for k=pos_start_learning(i):pos_end_learning(i)
        integrated_speed(k,:) = integrated_speed(k-1,:)+data.IMU_corrected(k,1:3)*(9.81/256)*parms.time_interval_twitch*10^-3;
        integrated_speed_2(k,:) = integrated_speed_2(k-1,:)+data_IMU_filtered(k,1:3)*(9.81/256)*parms.time_interval_twitch*10^-3;
    end
end

%%
figure;
text_list_channels = {'X','Y','Z'};
for i=1:3
subplot(2,2,i);
hold on;
plot(integrated_speed(index_start:index_end,i));
plot(integrated_speed_2(index_start:index_end,i));
plot(myfilter(integrated_speed(index_start:index_end,i)));
plot_patch_learning(gcf(),idx_start_learning,idx_end_learning,1);
legend('Raw IMU integrated','Filtered IMU integrated','Raw IMU integrated then filtered');
ylabel(['Speed ' text_list_channels{i} ' [m/s]']);
end
sgtitle('IMU accelerometer integrated signal');


%%
weights_speed = compute_weights_speed(data,lpdata,parms);

hinton_speed(weights_speed{parms.n_twitches},parms);
plot_weight_evolution_speed(weights_speed,parms);
