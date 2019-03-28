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
        bufferSize = 3000000; %TODO : size this buffer
        BaudRate = 2*10^6;
    end
    s=serial(strcat('COM',num2str(COMportID)),'BaudRate',BaudRate);
    s.InputBufferSize = bufferSize;
    s.Timeout = 100 + (parms.n_twitches * parms.n_m * parms.n_dir)...
        *(parms.duration_part0+parms.duration_part1+parms.duration_part2)/1000; %in seconds
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
file_name_data = strcat("../data/",time_stamp);
fprintf("Writing data to file: %s.mat\n", file_name_data);
save(file_name_data,'data_rec','pos_load_data_rec');





