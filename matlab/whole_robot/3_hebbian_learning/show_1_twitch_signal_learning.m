clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../plotting_functions');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 137;
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
n_iter = 1;
index_motor_plot = 10;
index_loadcell_plot = 1;
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
subplot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_plot,i_dir,parms,n_frames_theo,neutral_pos);
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

%%
function subplot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_plot,i_dir,parms,n_frames_theo,neutral_pos)
txt_channel_lc ={' X',' Y',' Z'};
theoretical_traj = compute_theoretical_traj_wrapper(i_dir,parms);
hold on;
plot(pos2deg(lpdata.motor_position(index_motor_plot,index_start:index_end),neutral_pos),'b-');
plot(pos2deg(lpdata.motor_positionfiltered(index_motor_plot,index_start:index_end),neutral_pos),'b--');
% plot(theoretical_traj(n_frames_theo.part0 + 1:n_frames_theo.part0 + n_frames_theo.part1),'k-');
xlabel('Sample index');
ylabel(['Motor ' num2str(index_motor_plot) ' Position [deg]']);
%     for i=1:parms.n_m
%      plot(lpdata.motor_position(i,index_start:index_end));
%     end
yyaxis right;
%plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,channel),'--');
% plot(data.float_value_time{1,index_loadcell_plot}(index_start:index_end,3),'k-');
plot(data.float_value_time{1,index_loadcell_plot}(index_start:index_end,index_channel_plot),'r-');
plot(data.s_lc_filtered(index_start:index_end,index_channel_plot+3*(index_loadcell_plot-1)),'r--');
ylabel(['LC ' num2str(index_loadcell_plot) txt_channel_lc{index_channel_plot} ' [N]']);
hold off;
ax=gca();
ax.YAxis(1).Color = 'b';
ax.YAxis(2).Color = 'r';
xlim([0 n_frames_theo.part1+1]);
title('Time Signals in Learning Window');
end

%% dot time signals
function subplot_dot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_plot,sign_learning,n_frames_theo)
conversion_factor = 3.413;
txt_channel_lc ={' X',' Y',' Z'};
hold on;
plot(sign_learning*lpdata.m_s_dot_pos(index_motor_plot,index_start:index_end)/conversion_factor,'b-');
plot(sign_learning*lpdata.m_s_dot_posfiltered(index_motor_plot,index_start:index_end)/conversion_factor,'b--');
plot([0 n_frames_theo.part1+1],[0.02 0.02],'Color',[0,0,1,0.2]);
xlabel('Sample index');
ylabel(['Motor ' num2str(index_motor_plot) ' speed [deg/ms]']);
ylim([-0.05 0.05]);
yyaxis right;
plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,index_channel_plot),'r-');
plot(data.s_dot_lc_filtered(index_start:index_end,index_channel_plot+3*(index_loadcell_plot-1)),'r--');
plot([0 n_frames_theo.part1+1],[0 0],'Color',[1,0,0,0.2]);
ylabel(['LC ' num2str(index_loadcell_plot) txt_channel_lc{index_channel_plot} 'differentiated [N/s]']);
%ylim([-100 100]);
xlim([0 n_frames_theo.part1+1]);
ax=gca();
ax.YAxis(1).Color = 'b';
ax.YAxis(2).Color = 'r';
ax.YAxis(2).Limits=max(abs(ax.YAxis(2).Limits))*[-1 1];
hold off;
title('Differentiated Signals in Learning Window');
end


function pos_deg = pos2deg(position,neutral_pos)
conversion_factor = 3.413;
if nargin == 1
    neutral_pos = 512;
end
pos_deg = (position-neutral_pos)/conversion_factor;
end

