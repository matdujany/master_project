clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../plotting_functions');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 81;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);

%%
weights_robotis  = read_weights_robotis(recordID,parms);
hinton_LC(weights_robotis{parms.n_twitches},parms,1);


%%
data = compute_filtered_signal_data(data,parms);
lpdata = compute_filtered_signal_lpdata(lpdata,parms);

good_closest_LC = get_good_closest_LC(parms,recordID);
%%
n_iter = 1;
index_motor_plot = 2;
index_loadcell_plot = 3;
% index_channel_plot = 2;
i_dir = 1;

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.4;

%%
f=figure;
for index_channel_plot = 1 : 3

% index_loadcell_plot = good_closest_LC(index_motor_plot);
index_sensor = index_channel_plot+3*(index_loadcell_plot-1);

n_frames_theo = get_theo_number_frames(parms);

index_start = n_frames_theo.per_twitch*(n_iter-1) + ...
    (n_frames_theo.per_action)*(index_motor_plot-1)*parms.n_dir +...
    (n_frames_theo.per_action)*(i_dir-1) + n_frames_theo.part0 + 1;

index_end = index_start+n_frames_theo.part1-1;


weights_read=read_weights_robotis(recordID,parms);
if n_iter == 1
    weights_init = 0;
else
    weights_init = weights_read{n_iter-1}(index_sensor,i_dir+2*(index_motor_plot-1));
end
m_dot=lpdata.m_s_dot_pos(index_motor_plot,index_start:index_end)';
s_dot = data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,index_channel_plot);
weights_det = compute_weight_detailled_evolution_helper(m_dot,s_dot, parms.eta, weights_init);

m_dot_filtered = lpdata.m_s_dot_posfiltered(index_motor_plot,index_start:index_end)';
s_dot_filtered = data.s_dot_lc_filtered(index_start:index_end,index_sensor);
weights_det_filtered = compute_weight_detailled_evolution_helper(m_dot_filtered,s_dot_filtered, parms.eta, weights_init);

subplot(2,3,index_channel_plot);
subplot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_plot,i_dir,parms,n_frames_theo);
grid on;
if index_channel_plot<3
    ylim([-3 0.5]);
end
subplot(2,3,3+index_channel_plot);
hold on;
plot(weights_det_filtered,'LineWidth',lineWidth);
% scatter(0,weights_init);
% scatter(n_frames_theo.part1,weights_read{n_iter}(index_sensor,i_dir+2*(index_motor_plot-1)));
title('Learning with filtered signals','FontSize',fontSize);
xlabel('Frame index','FontSize',fontSize);
ylabel('Weight value','FontSize',fontSize);
ax=gca();
ax.FontSize = fontSizeTicks;
ylim([-10 60]);
grid on;

end
f.Color = 'w';
f.Position = [ 1          41        1920         963];
%%
% export_fig figures_report/slippery_learning_corrupted_84.pdf;
export_fig figures_report/rugs_learning_notcorrupted_81.pdf;

%%
function subplot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_plot,i_dir,parms,n_frames_theo)
% theoretical_traj = compute_theoretical_traj_wrapper(i_dir,parms);

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.4;

txt_channel = {' X',' Y', ' Z'};
hold on;
plot(pos2deg(lpdata.motor_position(index_motor_plot,index_start:index_end)),'b-','LineWidth',lineWidth);
plot(pos2deg(lpdata.motor_positionfiltered(index_motor_plot,index_start:index_end)),'b--','LineWidth',lineWidth);
% plot(theoretical_traj(n_frames_theo.part0 + 1:n_frames_theo.part0 + n_frames_theo.part1),'k-');
xlabel('Frame index','FontSize',fontSize);
ylabel(['Motor ' num2str(index_motor_plot) ' Position [deg]']);
%     for i=1:parms.n_m
%      plot(lpdata.motor_position(i,index_start:index_end));
%     end
yyaxis right;
%plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,channel),'--');
plot(data.float_value_time{1,index_loadcell_plot}(index_start:index_end,index_channel_plot),'r-','LineWidth',lineWidth);
plot(data.s_lc_filtered(index_start:index_end,index_channel_plot+3*(index_loadcell_plot-1)),'r--','LineWidth',lineWidth);
ylabel(['Loadcell ' num2str(index_loadcell_plot) ' channel ' txt_channel{index_channel_plot} ' value [N]'],'FontSize',fontSize);
hold off;
ax=gca();
ax.YAxis(1).Color = 'b';
ax.YAxis(2).Color = 'r';
xlim([0 n_frames_theo.part1+1]);
title('Time Signals in Learning Window','FontSize',fontSize);
ax.FontSize = fontSizeTicks;
% ylim([-0.5 2.5]);

end

