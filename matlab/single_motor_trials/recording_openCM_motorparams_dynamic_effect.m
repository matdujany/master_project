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
frequency = recorded_data(end-6);
amplitude_oscillations = recorded_data(end-5);
compliance_margin = recorded_data(end-4);
compliance_slope = recorded_data(end-3);
punch = recorded_data(end-2);
nb_samples = recorded_data(end-1);
actual_duration = recorded_data(end);

motor_load = recorded_data(1:2:2*nb_samples);
motor_position = recorded_data(2:2:2*nb_samples+1);

time_ms = (1:nb_samples)*(actual_duration/nb_samples);
motor_command = 512 + amplitude_oscillations*sin(frequency*(time_ms/1000));

figure;
subplot(2,1,1);
plot(time_ms/1000,motor_load/10);
xlabel('Time [s]');
ylabel('Motor Load [% of maximal torque]');
subplot(2,1,2);
hold on;
plot(time_ms/1000,motor_position);
plot(time_ms/1000,motor_command);
legend('Actual Position', 'Command');
xlabel('Time [s]');
ylabel('Motor Position');

%%
figure;
plot(time_ms/1000,motor_load/10);
xlabel('Time [s]');
ylabel('Motor Load [% of maximal torque]');
yyaxis right
hold on;
plot(time_ms/1000,motor_position);
plot(time_ms/1000,motor_command);
hold off;
xlabel('Time [s]');
legend('Motor Load','Actual Position', 'Command');
ylabel('Motor Position');

%%
motor_params = struct();
osc_params = struct();

motor_params.punch = punch;
motor_params.compliance_margin = compliance_margin;
motor_params.compliance_slope = compliance_slope;
osc_params.frequency = frequency;
osc_params.amplitude_oscillations = amplitude_oscillations;
save('data_motorparms_dynamic_10','motor_load','motor_position','time_ms','motor_params','osc_params');


function deg = pos2deg(position)
deg = position/3.413 - 150;
end
