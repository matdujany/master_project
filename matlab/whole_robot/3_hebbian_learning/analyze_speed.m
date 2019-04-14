clear; 
close all; clc;

addpath('../2_load_data_code');

%% Load data
recordID = 14;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_robotis = read_weights_robotis(recordID,parms);
weights_pos_robotis = read_weights_pos_robotis(recordID,parms);


hinton_IMU(weights_robotis{parms.n_twitches},parms);

weights_speed = compute_weights_speed(data,lpdata,parms);

%%
hinton_speed(weights_speed{parms.n_twitches},parms);
plot_weight_evolution_speed(weights_speed,parms);
