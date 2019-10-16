clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../plotting_functions');
addpath('hinton_plot_functions');
addpath('computing_functions');
addpath('plot_functions');

%% Load data
recordID = 144;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
all_neutral_pos = read_neutral_pos(recordID,parms.n_m);

limb = get_good_limb(parms,recordID);

figure;
for i=1:parms.n_lc
    subplot(2,parms.n_lc/2,i)
    hold on;
    plot(lpdata.motor_position(limb(i,1),:));
    plot(lpdata.motor_position(limb(i,2),:));
    legend('Hip','Knee');
end
% plot(lpdata)