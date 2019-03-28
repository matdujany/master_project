
clear; 
close all; clc;

addpath('learning_functions');
addpath('../data');

%% Load data

record_list = [84:85];
max_dif_norm_pos = zeros(1,length(record_list));
max_dif_norm = zeros(1,length(record_list));
n_iter = 5;

flagPlot = 0;
flagFilter = 0;

for idx=1:length(record_list)
    recordID = record_list(idx);
    load(strcat(get_record_name(recordID),'_p'));
    add_parms;
    weights_pos_sim = compute_weights_pos_wrapper(data,lpdata,parms,flagFilter,flagPlot);
    weights_pos_read = read_weights_pos_robotis(recordID,parms);
    weights_sim = compute_weights_wrapper(data,lpdata,parms,flagFilter,flagPlot,0,0);
    weights_read = read_weights_robotis(recordID,parms);
    max_dif_norm_pos(1,idx) = check_weights_diff(weights_pos_sim,weights_pos_read,n_iter);
    max_dif_norm(1,idx) = check_weights_diff(weights_sim,weights_read,n_iter);
end