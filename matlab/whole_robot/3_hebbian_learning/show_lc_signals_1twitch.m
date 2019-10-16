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
n_iter = 4;
index_motor_plot = 6;
index_channel_plot = 3;
neutral_pos = all_neutral_pos(index_motor_plot);

%%
colors = lines(parms.n_lc);
for i_dir = 1 : 2

n_frames_theo = get_theo_number_frames(parms);

index_start = n_frames_theo.per_twitch*(n_iter-1) + ...
    (n_frames_theo.per_action)*(index_motor_plot-1)*parms.n_dir +...
    (n_frames_theo.per_action)*(i_dir-1) + n_frames_theo.part0 + 1;

index_end = index_start+n_frames_theo.part1-1;

f=figure;
f.Color = 'w';

txt_channel_lc ={' X',' Y',' Z'};
hold on;
for index_loadcell_plot = 1:parms.n_lc
    plot(data.float_value_time{1,index_loadcell_plot}(index_start:index_end,index_channel_plot),'Color',colors(index_loadcell_plot,:));
%     plot(data.s_lc_filtered(index_start:index_end,index_channel_plot+3*(index_loadcell_plot-1)),'Color',colors(index_loadcell_plot,:));
    legend_list{index_loadcell_plot} = ['LC ' num2str(index_loadcell_plot)];
end
ylabel(['LC ' num2str(index_loadcell_plot) txt_channel_lc{index_channel_plot} ' [N]']);
yyaxis right;
plot(pos2deg(lpdata.motor_position(index_motor_plot,index_start:index_end),neutral_pos),'k-');
ylabel(['Motor ' num2str(index_motor_plot) ' Position [deg]']);
legend_list{parms.n_lc+1} = 'Motor Position';
hold off;
legend(legend_list);
xlabel('Sample index');
ax=gca();
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';
xlim([0 n_frames_theo.part1+1]);
title('Time Signals in Learning Window');
end



function pos_deg = pos2deg(position,neutral_pos)
conversion_factor = 3.413;
if nargin == 1
    neutral_pos = 512;
end
pos_deg = (position-neutral_pos)/conversion_factor;
end

