%% ROBOTIS - MATLAB ANALYSIS
%  data_recording.m
%
%  DESCRIPTION:
%  Records data from the COM port
%
%  TO DO:
%
%  NOTES:
%  - Make sure to set the right parameters in the set_parameters file.

addpath('functions')

clear all; clc; close all;

if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

warning('off');

%% Parameters
set_parms
predict_duration(parms);
%% Main
time_vec   = clock;
time_stamp = strcat(num2str(time_vec(1)),"-",num2str(time_vec(2)),"-",num2str(time_vec(3)),"-",num2str(time_vec(4)),"_",num2str(time_vec(5)),"_",num2str(round(time_vec(6))));
disp(time_stamp);

poolobj= parpool('local',2);
spmd(2)
    if labindex == 1
        %daisychain (Serial2), blue cable, blue FTDI
        COMportID = 10;
        bufferSize = predict_n_bytes_approximate(parms);
        BaudRate = 500*10^3;
    else
        %lpdata (Serial3), yellow cable, red FTDI
        COMportID = 9;
        bufferSize = 5000000; %TODO : size this buffer
        BaudRate = 2*10^6;
    end
    s=serial(strcat('COM',num2str(COMportID)),'BaudRate',BaudRate);
    s.InputBufferSize = bufferSize;
    s.Timeout = predict_duration(parms); %in seconds
    flushinput(s);
    fprintf("\nGathering data...\n");
    fopen(s);
    out = fread(s);
    fclose(s);
    delete(s);
end
data_rec = out{1};
pos_load_data_rec = out{2};
delete(poolobj);
%%
file_name_data = strcat("../../../../data/",time_stamp);
fprintf("Writing data to file: %s.mat\n", file_name_data);
save(file_name_data,'data_rec','pos_load_data_rec','parms');


function n_byte_approx = predict_n_bytes_approximate(parms)
n_moves = parms.n_twitches * parms.n_m * parms.n_dir;
n_frames_p0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_p1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_p2 = floor(parms.duration_part2/parms.time_interval_twitch);
n_frames_learning = n_moves*(n_frames_p0+n_frames_p1+n_frames_p2);

%manual recentering
n_frames_recentering = parms.n_twitches * n_moves*ceil(parms.recentering_delay/parms.manual_recentering_time_interval_frame);
n_frames_manual_recentering = parms.n_twitches * ceil(parms.manual_recentering_duration*10^3/parms.manual_recentering_time_interval_frame);
%imu recalib
n_frames_calib = parms.n_twitches * parms.nb_values_mean_update_offset;

n_frames_approx = n_frames_learning + n_frames_recentering + n_frames_manual_recentering + n_frames_calib;

n_byte_approx = (parms.frame_size * n_frames_approx)*1.1;
end

%duration of the recording (for timeout) in seconds
function duration_approx = predict_duration(parms)
duration_approx =  (parms.n_twitches * parms.n_m * parms.n_dir)...
        *(parms.duration_part0+parms.duration_part1+parms.duration_part2)/1000; %in seconds

%automatic recentering between twitches
if parms.recentering == 1
    duration_approx = duration_approx + (parms.n_twitches * parms.n_m * parms.n_dir)*parms.recentering_delay/1000;
end

%manual recentering between twitch cycles
duration_approx = duration_approx + parms.n_twitches*parms.manual_recentering_duration;

%imu recalib
duration_approx = duration_approx + ...
    (parms.n_twitches*parms.nb_values_mean_update_offset*parms.delay_frames_update_offset/1000); % to recalibrate IMU

duration_approx = duration_approx + 100; %100 seconds to have a margin
end
