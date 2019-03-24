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

end_signal = 1500; %%has to be > than 1024 (openCM serialprints load and pos values which are < 1024)

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
n_twitches = recorded_data(end-10);
beginning_duration = recorded_data(end-9);
part0 = recorded_data(end-8);
part1 = recorded_data(end-7);
part2 = recorded_data(end-6);
recentering_duration = recorded_data(end-5);
nb_samples_static = recorded_data(end-4);
nb_samples_dynamic = recorded_data(end-3);
total_duration_static = recorded_data(end-2);
total_duration_dynamic = recorded_data(end-1);
n_motors = recorded_data(end);

%%
sampling_time_static = total_duration_static/nb_samples_static;
sampling_time_dynamic = total_duration_dynamic/nb_samples_dynamic;

n_servos = n_motors;


duration_static_theory = beginning_duration + (part1+part2)*2*n_servos*n_twitches +...
    recentering_duration*n_servos*n_twitches;
duration_dynamic_theory = part0*2*n_servos*n_twitches;


nb_samples = nb_samples_static+nb_samples_dynamic;
motor_positions=zeros(n_motors,nb_samples);
motor_loads=zeros(n_motors,nb_samples);

for m=1:n_motors
    motor_positions(m,:)=recorded_data(1+2*(m-1):2*n_motors:2*n_motors*nb_samples);
    motor_loads(m,:)=recorded_data(2*m:2*n_motors:2*n_motors*nb_samples);
end

build_timeline_progressive_twitch;

%%
figure;
legend_list=cell(n_motors,1);

subplot(2,1,1);
hold on;
for m=1:n_motors
    plot(timeline_ms/1000,motor_positions(m,:));
    legend_list{m}=strcat('M',num2str(m));
end
plot([1 timeline_ms(end)/1000],[512 512],'k--');
ylim([440 580]);
legend(legend_list);

subplot(2,1,2);
hold on;
for m=1:n_motors
    plot(timeline_ms/1000,motor_loads(m,:));
end
plot([1 timeline_ms(end)/1000],[0 0],'k--');
ylim([-600 600]);
legend(legend_list);

%%
save('pos_halfrobot_prog_both_2');