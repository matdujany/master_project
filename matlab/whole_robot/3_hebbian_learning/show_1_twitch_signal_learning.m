clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../plotting_functions');
addpath('hinton_plot_functions');
addpath('computing_functions');
addpath('plot_functions');

%% Load data
recordID = 149;
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

% good_closest_LC = get_good_closest_LC(parms,recordID);
%%
n_iter = 5;
index_motor_plot = 2;
index_loadcell_plot = 5;
index_channel_plot = 3;
neutral_pos = all_neutral_pos(index_motor_plot);

%%
for i_dir = 1 : 2

% index_loadcell_plot = good_closest_LC(index_motor_plot);
index_sensor = index_channel_plot+3*(index_loadcell_plot-1);

n_frames_theo = get_theo_number_frames(parms);


index_start = n_frames_theo.per_twitch*(n_iter-1) + ...
    (n_frames_theo.per_action)*(index_motor_plot-1)*parms.n_dir +...
    (n_frames_theo.per_action)*(i_dir-1) + n_frames_theo.part0 + 1;

index_end = index_start+n_frames_theo.part1-1;

if i_dir == 1
    %sign_learning = -1;
    sign_learning = 1;
else
     sign_learning = 1;
end  

weights_read=read_weights_robotis(recordID,parms);
if n_iter == 1
    weights_init = 0;
else
    weights_init = weights_read{n_iter-1}(index_sensor,i_dir+2*(index_motor_plot-1));
end
m_dot=sign_learning*lpdata.m_s_dot_pos(index_motor_plot,index_start:index_end)';
s_dot = data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,index_channel_plot);
weights_det = compute_weight_detailled_evolution_helper(m_dot,s_dot, parms.eta, weights_init);

m_dot_filtered = sign_learning*lpdata.m_s_dot_posfiltered(index_motor_plot,index_start:index_end)';
s_dot_filtered = data.s_dot_lc_filtered(index_start:index_end,index_sensor);
weights_det_filtered = compute_weight_detailled_evolution_helper(m_dot_filtered,s_dot_filtered, parms.eta, weights_init);


f=figure;
f.Color = 'w';
% subplot(2,2,1);
% subplot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_plot,i_dir,parms,n_frames_theo,neutral_pos);
% subplot(2,2,3);
% subplot_dot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_plot,sign_learning,n_frames_theo);
% subplot(2,2,2);
% hold on;
% plot(weights_det);
% scatter(0,weights_init);
% scatter(n_frames_theo.part1,weights_read{n_iter}(index_sensor,i_dir+2*(index_motor_plot-1)));
% title('Learning with unfiltered signals');
% subplot(2,2,4);
% hold on;
% plot(weights_det_filtered);
% scatter(0,weights_init);
% scatter(n_frames_theo.part1,weights_read{n_iter}(index_sensor,i_dir+2*(index_motor_plot-1)));
% title('Learning with filtered signals');
% xlabel('Sample index');
% ylabel('Weight value');

subplot(3,1,1);
subplot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_plot,parms,n_frames_theo,neutral_pos);
subplot(3,1,2);
subplot_dot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_plot,sign_learning,n_frames_theo);
subplot(3,1,3);
hold on;
plot(weights_det_filtered);
scatter(0,weights_init);
scatter(n_frames_theo.part1,weights_read{n_iter}(index_sensor,i_dir+2*(index_motor_plot-1)));
title('Learning with filtered signals');
xlabel('Sample index');
ylabel('Weight value');
f.Position = [  488.0000   41.8000  340.2000  740.8000];
sgtitle(['Iteration ' num2str(n_iter)]);
end




