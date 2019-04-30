clear; 
close all; clc;

%% Load data
addpath('../2_load_data_code');
addpath('computing_functions');
addpath('hinton_plot_functions');

recordID = 71;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);

weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis = read_weights_pos_robotis(recordID,parms);


opt_parms.motor_list = [1:16];
opt_parms.lc_list = [1:4];
plot_weight_evolution_LC_both(weights_robotis,parms,0,0,opt_parms);
% plot_weight_evolution_IMU(weights_robotis,parms);

hidediag=true;
% plot_weight_pos_evolution(weights_pos_robotis,parms,hidediag);

%%
hinton_LC(weights_robotis{5},parms);

% %%
% opt_parms.motor_list = [3 4];
% opt_parms.lc_list = [1 2 3 4];
% plot_weight_evolution_LC_both(weights_robotis,parms,0,0,opt_parms);
