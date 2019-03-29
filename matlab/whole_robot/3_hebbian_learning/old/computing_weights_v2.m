%% ROBOTIS - MATLAB ANALYSIS
% 
%  DESCRIPTION: 
%  This part selects the samples that are used to feed the Oja's learning 
%  rule and subsequently applies this rule to comupute weights

% TODO :  the findpeak could be done for each sensor
clear; 
close all; clc;

addpath('learning_functions');
addpath('../data');

%% Load data

recordID = 42;
load(strcat(get_record_name(recordID),'_p'));

% Add parameters to struct 'parms'
add_parms;
parms.eta = 1;

%%
n_frames_part0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_part2 = floor(parms.duration_part2/parms.time_interval_twitch);

nb_theo_frames = (n_frames_part0+n_frames_part1+n_frames_part2)*(parms.n_twitches*parms.n_m*parms.n_dir);

changes_frame = [n_frames_part0 n_frames_part0+n_frames_part1 n_frames_part0+n_frames_part1+n_frames_part2];
total_duration = n_frames_part0+n_frames_part1+n_frames_part2;

pos_start_learning = [n_frames_part0+1];
pos_end_learning   = [n_frames_part0+n_frames_part1];

for k=1:parms.n_twitches
    for i_motor = 1:parms.n_m
        for i_dir = 1:parms.n_dir
            pos_start_learning=[pos_start_learning pos_start_learning(end)+total_duration];
            pos_end_learning=[pos_end_learning pos_end_learning(end)+total_duration];
        end
    end
end
pos_start_learning(end)=[];
pos_end_learning(end)=[];

%%
if isfield(parms,'step_ampl')
    ylims = 512+parms.step_ampl*4*[-1 1];
else
    ylims = [470 550];
end
figure;
hold on;
plot(data.float_value_time{1}(:,1));
for i=1:length(pos_start_learning) 
    plot([pos_start_learning(i) pos_start_learning(i)],[-10 10],'b--');
    plot([pos_end_learning(i) pos_end_learning(i)],[-10 10],'r--');
end

figure;
hold on;
for i=1:length(pos_start_learning) 
    plot([pos_start_learning(i) pos_start_learning(i)],[470 550],'b--');
    plot([pos_end_learning(i) pos_end_learning(i)],[470 550],'r--');
end
for i=1:parms.n_m
    plot(lpdata.motor_position(i,:));
end
ylim(ylims);

if data.count_frames~=length(lpdata.last_motor_pos)
    disp('The number of frames found by Matlab in the Daisychain does not match the one found by openCM');
end

%% Creating s and s_dot matrix
s_dot_lc = zeros(data.count_frames-1,parms.n_lc * parms.n_ch_lc);
%-1 because the diff makes us lose 1 frame.
for i=1:parms.n_lc
    s_dot_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_dot_time{i};
end
s_dot_lc = [s_dot_lc;zeros(1,parms.n_lc * parms.n_ch_lc)]; %just adding a line of zeros

s_IMU = data.float_value_time{parms.n_lc+1}; %we dont diff the IMUS.
s_lc = zeros(data.count_frames,parms.n_lc * parms.n_ch_lc);
for i=1:parms.n_lc
    s_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_time{i};
end

%% create m_dot_matrix

m_dot_values = zeros(data.count_frames-1,1);
for i=1:data.count_frames-1
    m_dot_values(i)=(lpdata.last_motor_pos(i+1)-lpdata.last_motor_pos(i))/(lpdata.last_motor_timestamp(i+1)-lpdata.last_motor_timestamp(i));
end

%%
sensor_values = [s_dot_lc s_IMU(:,1:parms.n_useful_ch_IMU)];
weights = compute_weight_matrix(m_dot_values, sensor_values, pos_start_learning, pos_end_learning, parms);

%%
weights_robotis = read_weights_robotis(recordID,parms);

diff_weights = zeros(parms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU, parms.n_m * parms.n_dir);
diff_weights_norm = zeros(parms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU, parms.n_m * parms.n_dir);
k=parms.n_twitches;
for i = 1:parms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU
    for j = 1:parms.n_m * parms.n_dir
        diff_weights(i,j) = abs(weights_robotis{k}(i,j)-weights{k}(i,j));
        diff_weights_norm(i,j) = abs(weights_robotis{k}(i,j)-weights{k}(i,j))/abs(weights_robotis{k}(i,j));
    end
end

format shortG
disp('Difference between the weights computed by Robotis and my weights, in %');
disp(diff_weights_norm*100);

%%
plot_weight_evolution_LC(weights,parms)
plot_weight_evolution_IMU(weights,parms)

%%

function new_weight = update(old_weight,motor_learning,sensor_signal,parms)
nb_samples_learn = length(motor_learning);
if length(sensor_signal)~=length(motor_learning)
    disp('Pb with length of motor learning signal and sensory signal');
end
current_weight_value=old_weight;
for i=1:nb_samples_learn
    delta_weight = oja_diff_learning_rule(motor_learning(i), sensor_signal(i), current_weight_value);
    current_weight_value=current_weight_value+parms.eta*delta_weight;
end
new_weight = current_weight_value;
end


