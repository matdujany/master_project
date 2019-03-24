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
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);

%% Creating s and s_dot matrix
s_dot_lc = zeros(data.count_frames-1,parms.n_lc * parms.n_ch_lc);
%-1 because the diff makes us lose 1 frame.
for i=1:parms.n_lc
    s_dot_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_dot_time{i};
end
s_dot_lc = [zeros(1,parms.n_lc * parms.n_ch_lc);s_dot_lc]; %just adding a line of zeros

s_IMU = data.float_value_time{parms.n_lc+1}; %we dont diff the IMUS.
s_lc = zeros(data.count_frames,parms.n_lc * parms.n_ch_lc);
for i=1:parms.n_lc
    s_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_time{i};
end

%% create m_dot_matrix
[m_dot_learning,m_s_dot_pos] = compute_mdot_learning(data,lpdata,parms);

%%
sensor_values = [s_dot_lc s_IMU(:,1:parms.n_useful_ch_IMU)];
weights = compute_weight_matrix(m_dot_learning, sensor_values, pos_start_learning, pos_end_learning, parms);

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


