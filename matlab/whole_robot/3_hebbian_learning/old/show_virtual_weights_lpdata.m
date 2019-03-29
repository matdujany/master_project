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

recordID = 38;
load(strcat(get_record_name(recordID),'_p'));

%parms.eta = 10;

[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
%% Creating s_dot matrix
s_dot_pos = zeros(data.count_frames-1,parms.n_m);
s_dot_loads = zeros(data.count_frames-1,parms.n_m);

for i=1:parms.n_m
    s_dot_pos(:,i)=diff(lpdata.motor_position(i,:));
    s_dot_loads(:,i)=diff(lpdata.motor_load(i,:));
end

%% create m_dot_matrix

m_dot_values = zeros(data.count_frames-1,1);
for i=1:data.count_frames-1
    m_dot_values(i)=(lpdata.last_motor_pos(i+1)-lpdata.last_motor_pos(i))/(lpdata.last_motor_timestamp(i+1)-lpdata.last_motor_timestamp(i));
end

%%
weights_pos = compute_weight_matrix(m_dot_values, s_dot_pos, pos_start_learning, pos_end_learning, parms);
weights_loads = compute_weight_matrix(m_dot_values, s_dot_loads, pos_start_learning, pos_end_learning, parms);

plot_weight_pos_evolution(weights_pos,parms);

h=hinton(weights_pos{parms.n_twitches});
h=hinton(weights_loads{parms.n_twitches});