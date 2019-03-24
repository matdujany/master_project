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
COMport = 'COM6';
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
n_motors = recorded_data(end-2);
nb_samples = recorded_data(end-1);
actual_duration = recorded_data(end);

motor_signals=zeros(n_motors,nb_samples);
for m=1:n_motors
    motor_signals(m,:)=recorded_data(m:n_motors:n_motors*nb_samples);
end

time_ms = (1:nb_samples)*(actual_duration/nb_samples);

%%
figure;
legend_list=cell(n_motors,1);
hold on;
for m=1:n_motors
    plot(time_ms/1000,motor_signals(m,:));
    legend_list{m}=strcat('M',num2str(m));
end
plot([1 time_ms(end)/1000],[512 512],'k--');
legend(legend_list);
%%
parms.compliant_margin = 50;
parms.compliant_slope = 1;
parms.compliant_punch = 1;

parms.stiff_margin = 0;
parms.stiff_slope = 32;
parms.stiff_punch = 32;

save('pos_halfrobot_prog_1','motor_signals','time_ms','parms')
