
clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');

good_closest_LC = [3;3;4;4;1;1;2;2];

splitDirections = 0;
renorm = 0;
refine = 0;
n_iter = 5;
eta_sim = 10;

record_list = [4];
channelsSelected =[1 2 3]; %1 for X, 1 2 for X Y, 2 3 for Y Z etc ...

closest_sensors_sim = zeros(length(record_list),8);
%likelihoods_sim = zeros(length(record_list),8);
closest_sensors_read = zeros(length(record_list),8);
%likelihoods_read = zeros(length(record_list),8);
max_dif_norm = zeros(1,length(record_list));
score_read =  zeros(1,length(record_list));
score_sim =  zeros(1,length(record_list));

for i=1:length(record_list)
    recordID = record_list(i)
    [data, lpdata, parms] =  load_data_processed(recordID);
    add_parms;
    weights_read = read_weights_robotis(recordID,parms);
    weights_check = compute_weights_wrapper(data,lpdata,parms,0,0,0,0);
    max_dif_norm(1,i) = check_weights_diff(weights_check,weights_read,n_iter);
    
    parms_sim = parms;
    parms_sim.eta = eta_sim;
    weights_sim = compute_weights_wrapper(data,lpdata,parms_sim,1,0,0,0);
    [closest_sensors_read(i,:)] = find_closest_LC(weights_read,n_iter,splitDirections,channelsSelected,parms);
    [closest_sensors_sim(i,:)] = find_closest_LC(weights_sim,n_iter,splitDirections,channelsSelected,parms);
    %hinton_LC(weights_sim{n_iter},parms);
    %closest_sensors_sim(:,i)' 
    score_read(i) =sum(closest_sensors_read(i,:) == good_closest_LC');
    score_sim(i) =sum(closest_sensors_sim(i,:) == good_closest_LC');
    
end

%%
result_read = [score_read' closest_sensors_read];
results_sim = [score_sim' closest_sensors_sim];

%%
add_parms;
hinton_LC(weights_read{n_iter},parms);