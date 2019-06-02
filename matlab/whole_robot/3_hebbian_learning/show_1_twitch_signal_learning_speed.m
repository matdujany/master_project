clear; 
close all; clc;

addpath('../2_load_data_code');
addpath('../plotting_functions');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 116;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);

%%
weights_robotis  = read_weights_robotis(recordID,parms);
hinton_IMU(weights_robotis{parms.n_twitches},parms);

integrated_speed = compute_integrated_speed(data,lpdata,parms);
weights_speed = compute_weights_speed(data,lpdata,parms);
hinton_speed(weights_speed{parms.n_twitches},parms,1);
plot_weight_evolution_speed(weights_speed,parms);
%%
n_iter = 2;
index_motor_plot = 5;
index_channel_speed = 2;
bool_plot_lc_signal = false;

%%
for i_dir = 1:2

good_closest_LC = get_good_closest_LC(parms,recordID);
[motor_ids_dropoff,sign_direction_dropoff]= get_hardcoded_dropoff_results(parms);
idx_check = find(motor_ids_dropoff==index_motor_plot);
if ~isempty(idx_check)
    dir_dropoff = sign_direction_dropoff(idx_check(1));
    if (dir_dropoff == 1 && i_dir == 2) || (dir_dropoff == -1 && i_dir == 1)
        bool_plot_lc_signal=true;
    end
end

n_frames_theo = get_theo_number_frames(parms);

index_start = n_frames_theo.per_twitch*(n_iter-1) + ...
    (n_frames_theo.per_action)*(index_motor_plot-1)*parms.n_dir +...
    (n_frames_theo.per_action)*(i_dir-1) + n_frames_theo.part0 + 1;

index_end = index_start+n_frames_theo.part1-1;
%index_end = index_start+n_frames_part1;

data = compute_filtered_signal_data(data,parms);
lpdata = compute_filtered_signal_lpdata(lpdata,parms);

if bool_plot_lc_signal
    figure;
    plot(data.float_value_time{1,good_closest_LC(index_motor_plot)}(index_start:index_end,3));
end

figure;
sgtitle(['iteration ' num2str(n_iter)]);
%% time signals
subplot(2,2,1);
hold on;
plot(lpdata.motor_position(index_motor_plot,index_start:index_end),'b-');
plot(lpdata.motor_positionfiltered(index_motor_plot,index_start:index_end),'b--');
xlabel('Frame index');
ylabel(['Motor ' num2str(index_motor_plot) ' Position']);
yyaxis right;
plot(integrated_speed(index_start:index_end,index_channel_speed),'r-');
if bool_plot_lc_signal
    ax=gca();
    rescale_factor = max(abs(ax.YLim));
    data_lc_signal = data.float_value_time{1,good_closest_LC(index_motor_plot)}(index_start:index_end,3);
    data_lc_rescaled = rescale_factor*data_lc_signal/max(abs(data_lc_signal));
    plot(data_lc_rescaled,'k-');
end
ylabel(['Integrated speed ' num2str(index_channel_speed) ' (m/s)']);
hold off;
ax=gca();
ax.YAxis(1).Color = 'b';
ax.YAxis(2).Color = 'r';
xlim([0 n_frames_theo.part1+1]);
title('Time Signals in Learning Window');
%% dot time signals
subplot(2,2,3);
sign_learning = 1;
% if i_dir == 1
%     sign_learning = -1;
% else
%      sign_learning = 1;
% end  
hold on;
plot(sign_learning*lpdata.m_s_dot_pos(index_motor_plot,index_start:index_end),'b-');
plot(sign_learning*lpdata.m_s_dot_posfiltered(index_motor_plot,index_start:index_end),'b--');
xlabel('Frame index');
ylabel(['Learning Signal (+/- Motor ' num2str(index_motor_plot) ' speed)']);
ylim(0.2 * [-1 1]);
yyaxis right;
plot(integrated_speed(index_start:index_end,index_channel_speed),'r-');
plot([0 n_frames_theo.part1+1],[0 0],'Color',[1,0,0,0.2]);
ylabel(['Integrated speed ' num2str(index_channel_speed) ' (m/s)']);
%ylim([-100 100]);
xlim([0 n_frames_theo.part1+1]);
ax=gca();
ax.YAxis(1).Color = 'b';
ax.YAxis(2).Color = 'r';
hold off;
title('Differentiated Signals in Learning Window');

%%
weights_read=weights_speed;
if n_iter == 1
    weights_init = 0;
else
    weights_init = weights_read{n_iter-1}(index_channel_speed,i_dir+2*(index_motor_plot-1));
end

m_dot=sign_learning*lpdata.m_s_dot_pos(index_motor_plot,index_start:index_end)';

s_dot = integrated_speed(index_start:index_end,index_channel_speed);
weights_det = compute_weight_detailled_evolution_helper(m_dot,s_dot, parms.eta, weights_init);

m_dot_filtered = sign_learning*lpdata.m_s_dot_posfiltered(index_motor_plot,index_start:index_end)';
s_dot_filtered = integrated_speed(index_start:index_end,index_channel_speed);
weights_det_filtered = compute_weight_detailled_evolution_helper(m_dot_filtered,s_dot_filtered, parms.eta, weights_init);

%%
subplot(2,2,2);
hold on;
plot(weights_det);
scatter(0,weights_init);
scatter(n_frames_theo.part1,weights_speed{n_iter}(index_channel_speed,i_dir+2*(index_motor_plot-1)));
title('Learning with unfiltered signals');


subplot(2,2,4);
hold on;
plot(weights_det_filtered);
scatter(0,weights_init);
scatter(n_frames_theo.part1,weights_speed{n_iter}(index_channel_speed,i_dir+2*(index_motor_plot-1)));
title('Learning with filtered signals');

end