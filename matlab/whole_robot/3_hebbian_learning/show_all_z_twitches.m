clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('../plotting_functions');
addpath('hinton_plot_functions');
addpath('computing_functions');
addpath('plot_functions');

%% Load data
recordID = 146;
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
index_motor_plot = 7;
index_channel_lc_plot = 3;

neutral_pos = all_neutral_pos(index_motor_plot);

%%
for i_dir = 1 : 2
    f=figure;
    f.Color = 'w';
    
    for index_loadcell_plot = 1:parms.n_lc
        % index_loadcell_plot = good_closest_LC(index_motor_plot);
        index_sensor = index_channel_lc_plot+3*(index_loadcell_plot-1);
        
        n_frames_theo = get_theo_number_frames(parms);
        
        
        index_start = n_frames_theo.per_twitch*(n_iter-1) + ...
            (n_frames_theo.per_action)*(index_motor_plot-1)*parms.n_dir +...
            (n_frames_theo.per_action)*(i_dir-1) + n_frames_theo.part0 + 1;
        
        index_end = index_start+n_frames_theo.part1-1;
        
        
        subplot(2,parms.n_lc/2,index_loadcell_plot);
        subplot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_lc_plot,parms,n_frames_theo,neutral_pos);
    end
    
end

