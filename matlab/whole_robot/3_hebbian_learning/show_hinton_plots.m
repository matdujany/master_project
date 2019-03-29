clear; 
close all; clc;

addpath('../2_load_data_code');
recordID = 1;

[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_read = read_weights_robotis(recordID,parms);
weights_pos = read_weights_pos_robotis(recordID,parms);

n_iter=parms.n_twitches;
hinton_LC(weights_read{n_iter},parms);
