clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../plotting_functions');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 79;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);

%%
weights_robotis  = read_weights_robotis(recordID,parms);
weights_lc_time_signals = compute_weights_time_signals_lc(data,lpdata,parms,0,0,0,0);

hinton_LC(weights_lc_time_signals{parms.n_twitches},parms,1,'With time Signals');
hinton_LC(weights_robotis{parms.n_twitches},parms,1,'Normal');
