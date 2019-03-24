
clear all; clc; close all;

if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

%% parameters 
COMport = 'COM10';
Baud_Rate = 2*10^6; %use FTDI to print via Serial2.
timeout  = 1000; %%% timeout in seconds waiting for data.
n_bytes = 20000; % maximum number of bytes to be received

end_signal = 1500;

%% serial recording;
s = serial(COMport,'BaudRate',Baud_Rate);
s.InputBufferSize = n_bytes; % number of bytes to be receives
s.Timeout         = timeout;
s.InputBufferSize = n_bytes; % number of bytes to be receives
s.Timeout         = 1000; %%% timeout in seconds waiting for data.

flushinput(s)
fopen(s)
fprintf("\nGathering data...\n");
nb_samples = 0;

%we record everything until the end signal
while true
    out = fscanf(s,'%f');
    if out == end_signal
        break
    else
        nb_samples = nb_samples+1;
        recorded_data(nb_samples) = out;
    end
end
fclose(s)

%%
nb_samples = recorded_data(end-4);
time_start_step = recorded_data(end-3);
actual_duration = recorded_data(end-2);
initial_pos = recorded_data(end-1);
final_pos = recorded_data(end);
motor_position = recorded_data(1:nb_samples);

if sum(recorded_data(nb_samples+1:end-5))>0
    disp('Check the number of samples and the recording');
end

time_ms = (1:nb_samples)*(actual_duration/nb_samples);
motor_position_deg = motor_position/3.413 - 150;


figure;
hold on;
plot([time_start_step time_start_step],[240 785],'k--');
plot([0 time_start_step], [initial_pos initial_pos],'k--');
plot([actual_duration-400 actual_duration], [final_pos final_pos],'k--');
plot(time_ms,motor_position);
xticks(xticks_pos)
xlabel('Time [ms]');
ylabel('Motor Position [Pos]');

function deg = pos2deg(position)
deg = position/3.413 - 150;
end



