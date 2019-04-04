clear; 
close all; clc;


%% Load data
addpath('../2_load_data_code');
recordID = 13;
[data, lpdata, parms] =  load_data_processed(recordID);

% Add parameters to struct 'parms'
add_parms;
parms_sim = parms;
parms_sim.eta = 12;
weights_pos_check = compute_weights_pos_wrapper(data,lpdata,parms,0,0,0,0);
weights_pos_robotis  = read_weights_pos_robotis(recordID,parms);
max_dif_norm     = check_weights_diff(weights_pos_check,weights_pos_robotis,parms.n_twitches);

%%
flagPlot = 0;
flagDetailed = 1;
weights_detailed = compute_weights_pos_wrapper(data,lpdata,parms,0,flagPlot,flagDetailed);

hidediag = 1;
plot_weight_pos_evolution_detailed(weights_detailed,parms,hidediag,weights_pos_robotis);
