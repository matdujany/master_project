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

recordID = 7;
load(strcat(get_record_name(recordID),'_p'));

% Add parameters to struct 'parms'
add_parms

%% finding the indexes when the twitches start;
idx_moves = find_idx_twitch(data,parms);

%the data.m signal helps to make sure that the idx_moves been correctly
%selected
data.m = zeros(data.count_frames,1);
m_val = [-1,0,1,0];%we first twitch in the -1 direction then back to normal, then in +1 direction
for i = 1:length(idx_moves)-1
   i_m = mod(i-1,length(m_val)) + 1;
   m_tmp(idx_moves(i):idx_moves(i+1)) = m_val(i_m);
end
data.m(1:idx_moves(end)) =  m_tmp(:);

figure;
for i_ard = 1:parms.n_lc
subplot(2,1,i_ard)
hold on;
for j=1:3
plot(data.time(:,i_ard),data.float_value_time{i_ard}(:,j))
end
plot(data.time(:,i_ard),3*data.m);
hold off;
end

%% Hebbian Learning - sdot part
flagPlot=0;
s_dot_for_learning = fill_s_dot_learning_matrix(data,parms,idx_moves,flagPlot);

%% Hebbian Learning - Filling weight arrays
weights = fill_weight_arrays(s_dot_for_learning,parms);

%% comparing 
addpath('../data/recorded_weights_robotis');
weights_robotis = read_weights_robotis(recordID);

diff_step = zeros(parms.n_twitches,1);
for k=1:parms.n_twitches
    diff_step(k)=sum(sum(abs(weights_robotis{k}-weights{k})));
end

diff_action_sensor = zeros(parms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU, parms.n_m * parms.n_dir);
diff_action_sensor_norm = zeros(parms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU, parms.n_m * parms.n_dir);

for i = 1:parms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU
    for j = 1:parms.n_m * parms.n_dir
        for k=1:parms.n_twitches
            diff_action_sensor(i,j) = diff_action_sensor(i,j) +...
                abs(weights_robotis{k}(i,j)-weights{k}(i,j));
            diff_action_sensor_norm(i,j) = diff_action_sensor(i,j) +...
                abs(weights_robotis{k}(i,j)-weights{k}(i,j))/abs(weights_robotis{k}(i,j));                
        end
    end
end

disp('per action');
sum(diff_action_sensor_norm,1)
disp('per sensor');
sum(diff_action_sensor_norm,2)'

%%

hinton_IMU(weights_robotis{5},parms);
hinton_LC(weights_robotis{5},parms);

%%


