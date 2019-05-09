clear; 
close all; clc;


addpath('computing_functions');
addpath('hinton_plot_functions');

%% Load data
addpath('../2_load_data_code');
recordID = 88;
[data, lpdata, parms] =  load_data_processed(recordID);
parms = add_parms(parms);
weights_robotis  = read_weights_robotis(recordID,parms);
weights_chosen = weights_robotis; %sim or robotis

hinton_LC(weights_chosen{parms.n_twitches},parms,1);
hinton_LC_dissymmetry(weights_chosen{parms.n_twitches},parms,1);