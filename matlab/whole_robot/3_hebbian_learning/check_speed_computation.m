clear; 
close all; clc;


addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

export_plots = false;

%% Load data
recordID = 124;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);

weights_speed_robotis = cell(parms.n_twitches,1);
for k=1:parms.n_twitches
    weights_speed_robotis{k} = weights_robotis{k}(end-5:end-3,:);
end

%% computing speed (integration of IMU data)
weights_speed_comp = compute_weights_speed(data,lpdata,parms);
max_dif_norm = check_weights_diff(weights_speed_robotis,weights_speed_comp,5);

%%
hinton_speed(weights_speed_comp{5},parms,1);
%%
hinton_speed(weights_speed_robotis{5},parms,1);
