
clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');

%% Load data

n_legs = 6;
splitDirections = 0;
n_iter = 5;
eta_sim = 10;
flagPlot = 0;

switch n_legs
    case 4
        n_motors = 8;
    case 6
        n_motors = 12;
    otherwise
        disp('unknown number of legs');
end

record_list = [5];
channelsSelected =[1 2 3]; %1 for X, 1 2 for X Y, 2 3 for Y Z etc ...

good_pair = [1 3; 5 7; zeros(6,2)];
min_likelihoods = zeros(length(record_list),1);
good_pair_found = zeros(length(record_list),1);
min_likelihoods_sim = zeros(length(record_list),1);
good_pair_found_sim = zeros(length(record_list),1);
max_dif_norm = zeros(1,length(record_list));


for idx=1:length(record_list)
    recordID = record_list(i);
    [data, lpdata, parms] =  load_data_processed(recordID);
    add_parms;
    
    weights_pos_sim = compute_weights_pos_wrapper(data,lpdata,parms,flagPlot);
    weights_pos_filtered = compute_filtered_weights_pos_wrapper(data,lpdata,parms,flagPlot);
    weights_pos_read = read_weights_pos_robotis(recordID,parms);
    max_dif_norm(1,idx) = check_weights_diff(weights_pos_sim,weights_pos_read,n_iter);
    [likelihood_filtered,more_linked_other_sim,pairs_sim] = get_likelihood_hip_pairs(weights_pos_filtered,parms,n_iter);
    [likelihood,more_linked_other,pairs_read] = get_likelihood_hip_pairs(weights_pos_read,parms,n_iter);
    if norm(pairs_read(:,1:2)-good_pair)==0
        good_pair_found(idx)=1;
        min_likelihoods(idx)=min(pairs_read(pairs_read(:,3)>0,3));
    end
    if norm(pairs_sim(:,1:2)-good_pair)==0
        good_pair_found_sim(idx)=1;
        min_likelihoods_sim(idx)=min(pairs_sim(pairs_sim(:,3)>0,3));
    end
end

%%
add_parms;
hidediag = true;
hinton_pos(weights_pos_read{1},parms,hidediag);
hinton_pos(weights_pos_filtered{1},parms,hidediag);

