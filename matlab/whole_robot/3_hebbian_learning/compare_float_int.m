clear; 
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 92;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);


%%
weights_check = compute_weights_wrapper(data,lpdata,parms,0,0,0,0);

%%
hinton_LC(weights_robotis{5}/100,parms,1);
hinton_LC(weights_check{5},parms,1);


%%
weights_ratio = weights_robotis{5}/100./weights_check{5};
hinton_LC(weights_ratio*10,parms,1);
