clear; 
close all; clc;

%% Load data
addpath('../2_load_data_code');
addpath('computing_functions');
addpath('hinton_plot_functions');
addpath('../../export_fig');

recordID = 127;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);

weights_robotis  = read_weights_robotis(recordID,parms);
weights_speed = compute_weights_speed(data,lpdata,parms);


%%
h=hinton_full_with_speed(weights_robotis,weights_speed,parms,1);
% h.Position = [ 1           41         1536        749];
h.Position = [3          42        1639         954];
%%
% export_fig(['figures_report/full_hinton_' num2str(recordID) '_values.pdf'],h);