clear; 
close all; clc;


%% Load data
addpath('../2_load_data_code');
addpath('computing_functions');

recordID = 110;
[data, lpdata, parms] =  load_data_processed(recordID);
parms_sim = parms;
% parms_sim.eta = 20;
weights_check = compute_weights_wrapper(data,lpdata,parms,1,0,0,0,0);
weights_robotis  = read_weights_robotis(recordID,parms);
max_dif_norm     = check_weights_diff(weights_check,weights_robotis,parms.n_twitches);

%%
flagDetailed = 1;
flagSpeed=1;
weights_detailed = compute_weights_wrapper(data,lpdata,parms,flagSpeed,0,0,flagDetailed,0);

%%
[diff_norm_lc, diff_norm_IMU] = check_weights_detailed(weights_detailed,weights_robotis,parms);


%%
idx_motor = 3;
idx_dir = 2;
idx_lc = 2;
idx_channel = 2;
idx_weight_motor = idx_dir+2*(idx_motor-1);
idx_weight_sensor = idx_channel+3*(idx_lc-1);

n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
figure;
hold on;
plot(weights_detailed(:,idx_weight_sensor,idx_weight_motor));
% plot(weights_detailed_filtered(:,idx_weight_sensor,idx_weight_motor),'k--');
for k=1:parms.n_twitches
    scatter(k*n_frames_part1,weights_robotis{k}(idx_weight_sensor,idx_weight_motor),'rx');
end
xlabel('Learning Sample number');
ylabel('Weight Value');
% legend('Unfiltered','Filtered');
title(['Motor ' num2str(idx_motor) ', direction ' num2str(2*idx_dir-3) ', loadcell ' num2str(idx_lc), ', channel ' num2str(idx_channel)]);
%%
opt_parms.motor_list = [1:12];
opt_parms.lc_list = [1:3];
plot_weight_evolution_LC_both(weights_robotis,parms,1,weights_detailed,opt_parms);

%%

% n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
% figure;
% hold on;
% for k=1:parms.n_twitches
%     plot(weights_detailed_reinit(1+(k-1)*n_frames_part1:k*n_frames_part1,idx_weight_sensor,idx_weight_motor));
%     legend_list{k} = ['Twitch ' num2str(k)];
% end
% legend(legend_list)
% xlabel('Learning Sample number');
% ylabel('Weight Value (restarting at 0 at each twitch cycle)');
% title(['Motor ' num2str(idx_motor) ', direction ' num2str(2*idx_dir-3) ', loadcell ' num2str(idx_lc), ', channel ' num2str(idx_channel)]);

%%
% figure;
% plot(log(abs(weights_detailed(:,idx_sensor,idx_motor))));

% [m_dot_values,m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,1);
