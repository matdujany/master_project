%here i assume that the limbs have already been properly formed with limb
%assignment script.
% that the right directions for the hips have been determined with analyze
% z dropoff.
% that the right directions for the knees have been determined with analyze
% speed.


clear; 
close all; clc;


addpath('computing_functions');
addpath('hinton_plot_functions');

%% Load data
addpath('../2_load_data_code');
recordID = 63;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
% parms.n_useful_ch_IMU    = 6;
weights_robotis  = read_weights_robotis(recordID,parms);

switch parms.n_m
    case 8
        limb = [5     6;     7     8;     1     2;     3     4];
    case 12
        limb =  [9    10;   11    12;    1     2;     7     8;     5     6;     3     4];
        sign_hips = [-1; -1; 1; 1; 1; -1];
    otherwise
        disp ('unrecognized number of motors');
end

%%
renorm_factor = max(max(abs(weights_robotis{parms.n_twitches})));
weights = weights_robotis{parms.n_twitches}/renorm_factor;

hinton_LC(weights,parms,1);

%%
n_limb = size(limb,1);

