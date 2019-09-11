clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../plotting_functions');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 110;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
all_neutral_pos = read_neutral_pos(recordID,parms.n_m);

%%
weights_robotis  = read_weights_robotis(recordID,parms);
hinton_LC(weights_robotis{parms.n_twitches},parms,1);
hinton_LC_asymmetry(weights_robotis{parms.n_twitches},parms,1);


%%
data = compute_filtered_signal_data(data,parms);
lpdata = compute_filtered_signal_lpdata(lpdata,parms);

weights_check = compute_weights_wrapper(data,lpdata,parms,1,0,0,0,0);
weights_lc_robotis = weights_robotis{parms.n_twitches}(1:3*parms.n_lc,:);
weights_lc_check = weights_check{parms.n_twitches}(1:3*parms.n_lc,:);

weights_lc_diff_detailled = compute_weights_wrapper(data,lpdata,parms,1,0,0,1,0);
weights_lc_diff_detailled = weights_lc_diff_detailled(:,1:3*parms.n_lc,:);

%% using not differential hebbian learning instead
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
motor_pos_filtered = myfilter(lpdata.motor_position,parms.add_filter_size+1);
parms_not_diff = parms;
parms_not_diff.eta = 10^-6;
weights_lc_detailled = 10^3*compute_weight_detailled_evolution(motor_pos_filtered', data.s_lc_filtered, pos_start_learning, pos_end_learning, parms_not_diff, 0);

%%
i_lc =1;
i_motor = 5;

figure;
hold on;
for i_channel = 1:3
    plot(weights_lc_detailled(:,3*(i_lc-1)+i_channel,i_motor));
    plot(weights_lc_diff_detailled(:,3*(i_lc-1)+i_channel,i_motor));
end

