%this is to analyze roughly lpdata (position and load recorded during
%twitch experiment)
clear; 
close all; clc;

addpath('../2_load_data_code');

%% Load data
recordID = 55;
[data, lpdata, parms] =  load_data_processed(recordID);

%% Plot position
if isfield(parms,'step_ampl')
    ylims = 512+parms.step_ampl*4*[-1 1];
else
    ylims = [470 550];
end
figure;
hold on;
for i=1:parms.n_m
    plot(lpdata.motor_position(i,:));
end
ylim(ylims);

mean(lpdata.motor_position,2);

%% theoretical movement amplitude
% ampl_step_pos = floor(parms.step_ampl*3.413);
% n_frames_p1 = floor(parms.duration_part1/parms.time_interval_twitch);
% ampl_step_pos_ad = floor((n_frames_p1-1)/n_frames_p1*floor(parms.step_ampl*3.413));
% 
% 

