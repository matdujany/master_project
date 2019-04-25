clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../plotting_functions');

%% Load data
recordID = 62;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;

%%
weights_robotis = read_weights_robotis(recordID,parms);
hinton_LC(weights_robotis{parms.n_twitches},parms);

%%
i_twitch = 2;
i_lc = 3;

%% loadcell plots
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
pos_start_learning_cycle = pos_start_learning(1+(parms.n_m*parms.n_dir)*(i_twitch-1):parms.n_m*parms.n_dir*i_twitch);  
pos_end_learning_cycle = pos_end_learning(1+(parms.n_m*parms.n_dir)*(i_twitch-1):parms.n_m*parms.n_dir*i_twitch);  


n_frames_part0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_part2 = floor(parms.duration_part2/parms.time_interval_twitch);
nb_theo_frames_twitch = (n_frames_part0+n_frames_part1+n_frames_part2)*(parms.n_m*parms.n_dir);

i_start_twitch_cycle = 1+nb_theo_frames_twitch*(i_twitch-1) ;
i_end_twitch_cycle = nb_theo_frames_twitch*i_twitch;

% figure;
% for channel=1:3
%     subplot(2,2,channel);
%     hold on;
%     plot(data.float_value_time{1,i_lc}(i_start_twitch_cycle:i_end_twitch_cycle,channel));
%     plot_patch_learning(gcf(),pos_start_learning_cycle-i_start_twitch_cycle+1,pos_end_learning_cycle-i_start_twitch_cycle+1);
%     xlabel('Frame index');
%     ylabel('Load in N');
%     title(['Channel ' num2str(channel)]);
% end

%%
channel_plot = 3;
for i_lc_plot = 1:parms.n_lc
    figure;
    hold on;
    plot(data.float_value_time{1,i_lc_plot}(i_start_twitch_cycle:i_end_twitch_cycle,channel_plot));
    ax=gca();
    plot_patch_learning(ax.YLim,pos_start_learning_cycle-i_start_twitch_cycle+1,pos_end_learning_cycle-i_start_twitch_cycle+1,1);
    xlabel('Frame index');
    ylabel('Load in N');
    title(['Loadcell ' num2str(i_lc_plot) ' Channel ' num2str(channel_plot)]);
end