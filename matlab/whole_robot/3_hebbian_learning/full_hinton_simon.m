clear; 
close all; clc;


%% Load data
addpath('../2_load_data_code');
recordID = 15;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
parms.n_useful_ch_IMU    = 6;
weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis  = read_weights_pos_robotis(recordID,parms);

n_iter = parms.n_twitches;
weights = weights_robotis{n_iter};
weights_pos = weights_pos_robotis{n_iter};

%% hinton
h=hinton_full(weights_robotis,weights_pos_robotis,parms);

%% export
addpath('../../export_fig');
set(h,'Position',[50 50 1500 800]);
set(h,'PaperOrientation','landscape');
export_fig 'figures_simon/hinton_full_rescaled.pdf'

