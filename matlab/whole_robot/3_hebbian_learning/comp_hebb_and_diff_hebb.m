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
% hinton_LC_asymmetry(weights_robotis{parms.n_twitches},parms,1);


%%
data = compute_filtered_signal_data(data,parms);
lpdata = compute_filtered_signal_lpdata(lpdata,parms);

weights_check = compute_weights_wrapper(data,lpdata,parms,1,0,0,0,0);
weights_lc_robotis = weights_robotis{parms.n_twitches}(1:3*parms.n_lc,:);
weights_lc_check = weights_check{parms.n_twitches}(1:3*parms.n_lc,:);

weights_lc_diff_detailled = compute_weights_wrapper(data,lpdata,parms,1,0,0,1,0);
weights_lc_diff_detailled = weights_lc_diff_detailled(:,1:3*parms.n_lc,:);

weights_lc_diff_detailled_check = squeeze(weights_lc_diff_detailled(end,:,:));

%% using not differential hebbian learning instead
all_neutral_pos = read_neutral_pos(recordID,parms.n_m);

[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
motor_pos_filtered = myfilter(lpdata.motor_position,parms.add_filter_size+1);
parms_not_diff = parms;
parms_not_diff.eta = 10^-6;
weights_lc_detailled = 10^3*compute_weight_detailled_evolution(motor_pos_filtered'-all_neutral_pos, data.s_lc_filtered, pos_start_learning, pos_end_learning, parms_not_diff, 0);

weights_lc_detailled_check = squeeze(weights_lc_detailled(end,:,:));

%%
n_frames_theo = get_theo_number_frames(parms);

%%
i_lc_plot = 6;
i_channel = 3;
i_motor_plot = 1;
i_dir = 1;
n_iter = 1;
%%
index_start = n_frames_theo.per_twitch*(n_iter-1) + ...
    (n_frames_theo.per_action)*(i_motor_plot-1)*parms.n_dir +...
    (n_frames_theo.per_action)*(i_dir-1) + n_frames_theo.part0 + 1;

index_end = index_start+n_frames_theo.part1-1;


figure;
subplot(2,2,1);
subplot_time_signals(data,lpdata,index_start,...
    index_end,i_motor_plot,i_lc_plot,i_channel,i_dir,parms,n_frames_theo,all_neutral_pos(i_motor_plot));
subplot(2,2,3);
subplot_dot_time_signals(data,lpdata,index_start,...
    index_end,i_motor_plot,i_lc_plot,i_channel,1,n_frames_theo);
subplot(2,2,2);
plot(weights_lc_detailled(1+(n_iter-1)*n_frames_theo.part1:n_iter*n_frames_theo.part1,3*(i_lc_plot-1)+ i_channel,2*(i_motor_plot-1)+i_dir));
subplot(2,2,4);
hold on;
plot(weights_lc_diff_detailled(1+(n_iter-1)*n_frames_theo.part1:n_iter*n_frames_theo.part1,3*(i_lc_plot-1)+ i_channel,2*(i_motor_plot-1)+i_dir));
if n_iter>1
    scatter(1,weights_robotis{n_iter-1}(3*(i_lc_plot-1)+ i_channel,2*(i_motor_plot-1)+i_dir));
else
    scatter(1,0);
end
scatter(n_frames_theo.part1,weights_robotis{n_iter}(3*(i_lc_plot-1)+ i_channel,2*(i_motor_plot-1)+i_dir));



