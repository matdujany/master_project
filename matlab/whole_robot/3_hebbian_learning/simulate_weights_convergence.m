clear; 
close all; clc;

%% Load data
addpath('../2_load_data_code');
addpath('computing_functions');

recordID = 105;
[data, lpdata, parms] =  load_data_processed(recordID);

weights_check = compute_weights_wrapper(data,lpdata,parms,0,0,0,0);
weights_robotis  = read_weights_robotis(recordID,parms);

% max_dif_norm     = check_weights_diff(weights_check,weights_robotis,parms.n_twitches);


%plot_weight_evolution_LC(weights_sim,parms_sim);
%plot_weight_evolution_IMU(weights_sim,parms_sim);
hidediag=true;
%plot_weight_pos_evolution(weights_pos_sim,parms_sim,hidediag);

%% normal weights
reps = 5;
flagFilter = 0;
parms_sim = parms;
parms_sim.n_twitches =1 ;
weights_init{1}=weights_check{1};
weights_sim = simulate_weights(data,lpdata,parms_sim,reps,0,0,0,weights_init);
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
