clear; 
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 115;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);


%%
weights_check = compute_weights_wrapper(data,lpdata,parms,0,0,0,0);

%%
n_iter = 2;

%%
hinton_LC(weights_robotis{n_iter},parms,1);
hinton_LC(weights_check{n_iter},parms,1);


%%
weights_ratio = weights_robotis{n_iter}./weights_check{n_iter};
hinton_LC(weights_ratio,parms,1);


%%
hinton_IMU(weights_robotis{n_iter},parms,1);
hinton_IMU(weights_check{n_iter},parms,1);
%%
hinton_IMU(weights_ratio,parms,1);
