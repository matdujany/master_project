clear;
clc;
close all;


i_dir = 1;

duration_part0 = 50;
duration_part1 = 360;
time_interval_twitch = 20;
n_frames_part0 = floor(duration_part0/time_interval_twitch);
n_frames_part1 = floor(duration_part1/time_interval_twitch);

slope = 2;

theoretical_traj = 512*ones(1,n_frames_part0);
signs = [-1;1];
for i=1:n_frames_part1
    theoretical_traj(1,n_frames_part0+i) = 512 +signs(i_dir)*slope*i;
end

plot(theoretical_traj);

amplitude_deg = compute_amplitude_ramp(slope,duration_part1,time_interval_twitch);

function amplitude_deg =  compute_amplitude_ramp(slope,duration_part1,time_interval_twitch)
n_frames_part1 = floor(duration_part1/time_interval_twitch);
ampl_step_pos = n_frames_part1*slope;
amplitude_deg=ampl_step_pos/3.413;
end