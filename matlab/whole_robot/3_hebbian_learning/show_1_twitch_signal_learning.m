clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../plotting_functions');

%% Load data
recordID = 71;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);

%%
weights_robotis  = read_weights_robotis(recordID,parms);
hinton_LC(weights_robotis{parms.n_twitches},parms);


%%
good_closest_LC = get_good_closest_LC(parms,recordID);
n_iter = 1;
index_motor_plot = 7;
i_dir = 1;
index_loadcell_plot = 2;
index_channel_plot = 2;

% index_loadcell_plot = good_closest_LC(index_motor_plot);
index_sensor = index_channel_plot+3*(index_loadcell_plot-1);

n_frames_theo = get_theo_number_frames(parms);

index_start = n_frames_theo.per_twitch*(n_iter-1) + ...
    (n_frames_theo.per_action)*(index_motor_plot-1)*parms.n_dir +...
    (n_frames_theo.per_action)*(i_dir-1) + n_frames_theo.part0 + 1;

index_end = index_start+n_frames_theo.part1-1;
%index_end = index_start+n_frames_part1;

data = compute_filtered_signal_data(data,parms);
lpdata = compute_filtered_signal_lpdata(lpdata,parms);

figure;
%% time signals
subplot(2,2,1);
hold on;
plot(lpdata.motor_position(index_motor_plot,index_start:index_end),'b-');
plot(lpdata.motor_positionfiltered(index_motor_plot,index_start:index_end),'b--');
xlabel('Frame index');
ylabel(['Motor ' num2str(index_motor_plot) ' Position']);
%     for i=1:parms.n_m
%      plot(lpdata.motor_position(i,index_start:index_end));
%     end
yyaxis right;
%plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,channel),'--');
plot(data.float_value_time{1,index_loadcell_plot}(index_start:index_end,index_channel_plot),'r-');
plot(data.s_lc_filtered(index_start:index_end,index_sensor),'r--');
ylabel(['Loadcell ' num2str(index_loadcell_plot) ' channel ' num2str(index_channel_plot) ' value [N]']);
hold off;
ax=gca();
ax.YAxis(1).Color = 'b';
ax.YAxis(2).Color = 'r';
xlim([0 n_frames_theo.part1+1]);
title('Time Signals in Learning Window');
%% dot time signals
subplot(2,2,3);
if i_dir == 1
    sign_learning = -1;
else
     sign_learning = 1;
end  
hold on;
plot(sign_learning*lpdata.m_s_dot_pos(index_motor_plot,index_start:index_end),'b-');
plot(sign_learning*lpdata.m_s_dot_posfiltered(index_motor_plot,index_start:index_end),'b--');
xlabel('Frame index');
ylabel(['Learning Signal (+/- Motor ' num2str(index_motor_plot) ' speed)']);
ylim([0 0.2]);
yyaxis right;
plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,index_channel_plot),'r-');
plot(data.s_dot_lc_filtered(index_start:index_end,index_sensor),'r--');
plot([0 n_frames_theo.part1+1],[0 0],'Color',[1,0,0,0.2]);
ylabel(['Loadcell ' num2str(index_loadcell_plot) ' channel ' num2str(index_channel_plot) ' differentiated value [N/s]']);
%ylim([-100 100]);
xlim([0 n_frames_theo.part1+1]);
ax=gca();
ax.YAxis(1).Color = 'b';
ax.YAxis(2).Color = 'r';
hold off;
title('Differentiated Signals in Learning Window');

%%
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

%%
subplot(2,2,2);
hold on;
plot(weights_det);
scatter(0,weights_init);
scatter(n_frames_theo.part1,weights_read{n_iter}(index_sensor,i_dir+2*(index_motor_plot-1)));
title('Learning with unfiltered signals');


subplot(2,2,4);
hold on;
plot(weights_det_filtered);
scatter(0,weights_init);
scatter(n_frames_theo.part1,weights_read{n_iter}(index_sensor,i_dir+2*(index_motor_plot-1)));
title('Learning with filtered signals');
