clear; 
close all; clc;

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 87;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);

weights = weights_robotis{parms.n_twitches};
weights_lc = weights(1:3*parms.n_lc,:);
weights_lc = 100 * weights_lc/max(max(abs(weights_lc))) ;
h=hinton_LC(weights_lc,parms,1);

hinton_LC_dissymetry(weights_lc,parms,1);

addpath('../../export_fig');
set(h,'Position',[10 10 1800 980]);
set(h,'PaperOrientation','landscape');
% export_fig 'figures/recordID86_weights_LC.pdf'