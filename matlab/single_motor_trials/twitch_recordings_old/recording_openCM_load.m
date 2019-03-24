%%% this is to be used with serial_recording_follow_speed of Robotis.
%%% the parameters to tune for the sine to follow (amplitude and frequency)
%%% are also in the ino script
%%% FTDI is plugged on Serial2, pin A4
%%% in that mode the frequency increases linearly with time between
%%% frequency_start and frequency_end (see inos script for parameters).

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

nb_samples = recorded_data(end-1);
actual_duration = recorded_data(end);

motor_load = recorded_data(1:2:2*nb_samples);
motor_position = recorded_data(2:2:2*nb_samples+1);

time_ms = (1:nb_samples)*(actual_duration/nb_samples);

figure;
subplot(2,1,1);
plot(time_ms/1000,motor_load/10);
xlabel('Time [s]');
ylabel('Motor Load [% of maximal torque]');
subplot(2,1,2);
plot(time_ms/1000,motor_position);
xlabel('Time [s]');
ylabel('Motor Position');

%%
figure;
plot(time_ms/1000,motor_load/10);
xlabel('Time [s]');
ylabel('Motor Load [% of maximal torque]');
yyaxis right
plot(time_ms/1000,motor_position);
xlabel('Time [s]');
ylabel('Actual Motor Position');


function deg = pos2deg(position)
deg = position/3.413 - 150;
end
