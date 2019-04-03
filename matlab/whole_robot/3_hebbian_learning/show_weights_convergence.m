clear; 
close all; clc;

%% Load data
addpath('../2_load_data_code');
recordID = 11;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;

weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis = read_weights_pos_robotis(recordID,parms);

plot_weight_evolution_LC(weights_robotis,parms);
plot_weight_evolution_IMU(weights_robotis,parms);

hidediag=true;
plot_weight_pos_evolution(weights_pos_robotis,parms,hidediag);