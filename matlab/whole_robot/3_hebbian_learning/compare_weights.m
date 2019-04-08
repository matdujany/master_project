clear; 
close all; clc;


%% Load data
addpath('../2_load_data_code');
recordID1 = 15;
recordID2 = 23;
n_iter = 5;

[~, ~, parms] =  load_data_processed(recordID1);
add_parms;
weights_robotis1  = read_weights_robotis(recordID1,parms);
weights1 = weights_robotis1{n_iter};

weights_robotis2  = read_weights_robotis(recordID2,parms);
weights2 = weights_robotis2{n_iter};

%%
weights_diff = 2*(weights2-weights1)./(abs(weights1)+abs(weights2));
%%
hinton_LC_2(weights1',parms,1);
hinton_LC_2(weights2',parms,1);
%%
hinton_LC_2(weights_diff',parms);