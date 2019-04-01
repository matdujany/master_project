clear; 
close all; clc;

%% Load data
addpath('../2_load_data_code');
recordID = 6;
[data, lpdata, parms] =  load_data_processed(recordID);

%%
n_frames_p0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_p1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_p2 = floor(parms.duration_part2/parms.time_interval_twitch);
n_frames_action = n_frames_p0+n_frames_p1+n_frames_p2;

%%
time_ints = diff(data.time);
idx = find(time_ints > parms.time_interval_twitch);