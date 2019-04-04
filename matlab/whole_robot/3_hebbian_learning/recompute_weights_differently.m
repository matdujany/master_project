clear; 
close all; clc;

%% Load data
addpath('../2_load_data_code');
recordID = 5;
[data, lpdata, parms] =  load_data_processed(recordID);
flagPlot = 0;
flagFiltersim = 0;
eta_sim = 10;

% Add parameters to struct 'parms'
add_parms;
parms_sim = parms;
parms_sim.eta = eta_sim;
parms_sim.use_filter = 1;
parms_sim.add_filter_size = 3;
weights_sim = compute_weights_wrapper(data,lpdata,parms_sim,flagFiltersim,flagPlot,0,0);
weights_pos_sim = compute_weights_pos_wrapper(data,lpdata,parms_sim,flagFiltersim,flagPlot);

weights_check = compute_weights_wrapper(data,lpdata,parms,0,flagPlot,0,0);
weights_pos_check = compute_weights_pos_wrapper(data,lpdata,parms,0,flagPlot);
weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis = read_weights_pos_robotis(recordID,parms);
max_dif_norm     = check_weights_diff(weights_check,weights_robotis,parms.n_twitches);
max_dif_norm_pos = check_weights_diff(weights_pos_check,weights_pos_robotis,parms.n_twitches);


hinton_LC(weights_robotis{5},parms);
hinton_LC(weights_sim{5},parms);
