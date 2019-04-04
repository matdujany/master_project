clear; 
close all; clc;

%% Load data
addpath('../2_load_data_code');
recordID = 15;
[data, lpdata, parms] =  load_data_processed(recordID);
flagPlot = 0;
flagFiltersim = 0;
eta_sim = 10;

% Add parameters to struct 'parms'
add_parms;
parms_sim = parms;
parms_sim.eta = eta_sim;
parms_sim.use_filter = 0;
weights_sim = compute_weights_wrapper(data,lpdata,parms_sim,flagFiltersim,flagPlot,0,0);
weights_pos_sim = compute_weights_pos_wrapper(data,lpdata,parms_sim,flagFiltersim,flagPlot);

weights_check = compute_weights_wrapper(data,lpdata,parms,0,flagPlot,0,0);
weights_pos_check = compute_weights_pos_wrapper(data,lpdata,parms,0,flagPlot);
weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis = read_weights_pos_robotis(recordID,parms);
max_dif_norm     = check_weights_diff(weights_check,weights_robotis,parms.n_twitches);
max_dif_norm_pos = check_weights_diff(weights_pos_check,weights_pos_robotis,parms.n_twitches);


%plot_weight_evolution_LC(weights_sim,parms_sim);
%plot_weight_evolution_IMU(weights_sim,parms_sim);
hidediag=true;
%plot_weight_pos_evolution(weights_pos_sim,parms_sim,hidediag);

%% normal weights
% reps = 5;
% flagFilter = 1;
% weights_sim = simulate_weights(data,lpdata,parms_sim,reps,0,flagFilter,flagPlot,weights_filtered);
% parms_sim.n_twitches =  parms.n_twitches*reps;
% 
% plot_weight_evolution_LC(weights_sim,parms_sim);
% %plot_weight_evolution_IMU(weights_sim,parms_sim);
% 
% hinton_LC(weights_sim{parms_sim.n_twitches},parms_sim);

%% weights pos
% reps = 1;
% flagFilter = 1;
% parms_sim = parms;
% parms_sim.eta = eta_sim;
% weights_pos_sim = simulate_weights(data,lpdata,parms_sim,reps,1,flagFilter,flagPlot,weights_pos_filtered);
% parms_sim.n_twitches =  parms.n_twitches*reps;
% 
% hidediag=true;
% plot_weight_pos_evolution(weights_pos_sim,parms_sim,hidediag);
% hinton_pos(weights_pos_sim{parms_sim.n_twitches},parms_sim,hidediag);
