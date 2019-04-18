
clear;
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../../tight_subplot');


%% Load data
recordID = 56;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights = read_weights_robotis(recordID,parms);
weights_pos = read_weights_pos_robotis(recordID,parms);

idx_twitch = 2;

%%
% hinton_pos(weights_pos{parms.n_twitches},parms,0);
hinton_LC(weights{parms.n_twitches},parms);
% hinton_IMU(weights{parms.n_twitches},parms);
% hinton_full(weights,weights_pos,parms);

%% computing learning signals
data = compute_filtered_signal_data(data,parms);
s_dot_lc = data.s_dot_lc_filtered;
s_IMU = data.s_IMU_filtered;
[m_dot_values,m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,1);

%%
% subplots_z_loadcells(idx_twitch,s_dot_lc,parms);
% 
list_hip_motors = [1 2 5 6 9 10 13 14];
subplots_z_loadcells(idx_twitch,s_dot_lc,parms,list_hip_motors);

%%
flagPlot = 1;
threshold_factor = 0.2;
dropoffs = count_dropoffs(threshold_factor,data,parms,flagPlot);
