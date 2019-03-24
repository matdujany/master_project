
clear all; clc; close all;

if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

%% parameters 
set_parms;
COMport = 'COM9';
Baud_Rate = 2*10^6; %use FTDI to print via Serial2.
timeout  = 1000; %%% timeout in seconds waiting for data.
n_bytes = 200000; % maximum number of bytes to be received
end_signal = 1500;

%% serial recording;
s = serial(COMport,'BaudRate',Baud_Rate);
s.InputBufferSize = n_bytes; % number of bytes to be receives
s.Timeout         = timeout;

flushinput(s)
fopen(s)
fprintf("\nGathering load and pos data...\n");
nb_samples = 0;

%we record everything until the end signal
while true
    out = fscanf(s,'%f');
    if out == end_signal
        break
    else
        nb_samples = nb_samples+1;
        pos_load_data(nb_samples) = out;
    end
end
fclose(s)

%%
file_name_save = 'last_pos_load_data';
save(file_name_save,'pos_load_data');


