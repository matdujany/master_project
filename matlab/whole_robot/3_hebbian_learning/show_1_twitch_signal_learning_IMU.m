clear; 
close all; clc;

addpath('../2_get_data_code');

%% Load data
recordID = 9;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;

%%
good_closest_LC = [3;3;4;4;1;1;2;2];%just to pick motor and loadcells which are related.

n_iter = 1;
index_motor_plot = 2;
i_dir = 2;
index_channel_IMU