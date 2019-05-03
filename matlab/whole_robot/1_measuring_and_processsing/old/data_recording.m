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
n_bytes  = predict_n_bytes_approximate(parms); 
time_vec   = clock;
time_stamp = strcat(num2str(time_vec(1)),"-",num2str(time_vec(2)),"-",num2str(time_vec(3)),"-",num2str(time_vec(4)),"_",num2str(time_vec(5)),"_",num2str(round(time_vec(6))));
data_rec = record_data(parms.COMport,n_bytes);

%%
load('last_pos_load_data');
file_name_data = strcat("../data/",time_stamp);
fprintf("Writing data to file: %s.mat\n", file_name_data);
save(file_name_data,'data_rec','pos_load_data');

%% Functions 

function out = record_data(COMport, n_bytes, Baud_Rate, file_name)

if nargin == 1
    n_bytes   = 1024;
    Baud_Rate = 57600;
    file_name = 'MySerialFile.txt';
end

if nargin == 2
    Baud_Rate = 57600;
    file_name = 'MySerialFile.txt';
end

if nargin == 3
    file_name = 'MySerialFile.txt';
end

s = serial(strcat('COM',COMport),'BaudRate',Baud_Rate);

s.InputBufferSize = n_bytes;
s.Timeout         = 120; %in seconds

flushinput(s)
fopen(s)
s.RecordDetail      = 'verbose';
s.RecordName        = file_name;
fprintf("\nGathering data...\n");
record(s,'on')
out                 = fread(s);
record(s,'off')
fclose(s)

if isempty(out)
   fprintf("\nNo data recorded, make sure you reset the Robotis before recording.\n");
end

end





