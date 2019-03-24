%% ROBOTIS - MATLAB ANALYSIS
% 
%  DESCRIPTION: 
%  This script analyses the weights to infer possible connection links
%  between motors and sensors. The evolution of these links with the number
%  of twitch iterations is also shown.

clear;
close all; clc;

addpath('learning_functions');
addpath('../data');

%% Load data

recordID = 6;
load(strcat(get_record_name(recordID),'_p'));
add_parms;
weights = read_weights_robotis(recordID,parms);

n_iter = parms.n_twitches;


%% showing the weights
hinton_LC(weights{n_iter},parms);
%hinton_IMU(weights{n_iter},parms);
%plot_weight_evolution_LC(weights,parms)
%plot_weight_evolution_IMU(weights,parms)

%% aim find the motors that produce the same reactions
%proximity :
n_iter = parms.n_twitches;

index_LC = 1:parms.n_lc*parms.n_ch_lc;
%functional_proximity_graph_both(weights,n_iter,index_LC,parms,'Using loadcell channels only');

index_IMU = parms.n_lc*parms.n_ch_lc+1:parms.n_lc*parms.n_ch_lc+parms.n_useful_ch_IMU;
%functional_proximity_graph_both(weights,n_iter,index_IMU,parms,'Using IMU only');

%functional_proximity_graph_both(weights,n_iter,[index_LC index_IMU],parms,'Using IMU and LC');

%% Showing the final motor sensor graph.
motor_sensor_graph

%%
n_iter = parms.n_twitches;
fused_weight=zeros(parms.n_lc*parms.n_ch_lc+parms.n_useful_ch_IMU,parms.n_m);
for i=1:parms.n_m
    fused_weight(:,i)=sum(abs(weights{n_iter}(:,1+2*(i-1):2*i)),2);
end

%% evolution closest load sensor
evolution_closest_LC

%% evolution closest IMU
%evolution_closest_IMU