%this is to study the variability of the motor movement from one twitching
%to an other

clear; 
close all; clc;

addpath('../2_get_data_code');

%% Load data
recordID = 1;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;

%%
[lpdata,data,idx_start,idx_end] = compute_avg_cycles(lpdata,data,parms);

index_motor_plot = 5;

n_frames_part0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_part2 = floor(parms.duration_part2/parms.time_interval_twitch);
n_frames_1_twitch = n_frames_part0 + n_frames_part1 + n_frames_part2;
n_frames_whole_twitch = n_frames_1_twitch*2*parms.n_m;
n_frames_start = n_frames_1_twitch * 2 *(index_motor_plot-1) + 1 ;

for k=1:parms.n_twitches
    idx_start(k,1) = (k-1)*n_frames_whole_twitch + n_frames_start;
    idx_end(k,1) = idx_start(k,1) + n_frames_1_twitch*2;
end

%%
figure;
hold on;
for k=1:parms.n_twitches
    plot(lpdata.motor_position(index_motor_plot,idx_start(k,1):idx_end(k,1)));
end
ylabel('Motor Position');
xlabel('Frame Index');
title(['Motor ' num2str(index_motor_plot)]);