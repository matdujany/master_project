clear; 
close all; clc;

addpath('../data');

%% Load data
recordID = 73;
load(strcat(get_record_name(recordID),'_p'));

% Add parameters to struct 'parms'
add_parms;
parms_sim = parms;
parms_sim.eta = 1;
weights_check = compute_weights_wrapper(data,lpdata,parms,0,0,0,0);
weights_robotis  = read_weights_robotis(recordID,parms);
max_dif_norm     = check_weights_diff(weights_check,weights_robotis,parms.n_twitches);

%%
flagPlot = 0;
flagDetailed = 1;
weights_detailed = compute_weights_wrapper(data,lpdata,parms,0,flagPlot,flagDetailed,0);
weights_detailed_filtered = compute_weights_wrapper(data,lpdata,parms,1,flagPlot,flagDetailed,0);

weights_detailed_reinit = compute_weights_wrapper(data,lpdata,parms,0,flagPlot,flagDetailed,1);

%%
diff_norm = check_weights_detailed(weights_detailed,weights_robotis,parms);


%%
idx_motor = 1;
idx_dir = 1;
idx_lc = 2;
idx_channel = 2;
idx_weight_motor = idx_dir+2*(idx_motor-1);
idx_weight_sensor = idx_channel+3*(idx_lc-1);

n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
figure;
hold on;
plot(weights_detailed(:,idx_weight_sensor,idx_weight_motor));
plot(weights_detailed_filtered(:,idx_weight_sensor,idx_weight_motor),'k--');
for k=1:parms.n_twitches
    scatter(k*n_frames_part1,weights_robotis{k}(idx_weight_sensor,idx_weight_motor),'rx');
end
legend('Unfiltered','Filtered');

plot_weight_evolution_LC_detailed(weights_detailed,parms,weights_robotis);
plot_weight_evolution_LC_detailed(weights_detailed_filtered,parms,weights_robotis);

%%

n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
figure;
hold on;
for k=1:parms.n_twitches
    plot(weights_detailed_reinit(1+(k-1)*n_frames_part1:k*n_frames_part1,idx_weight_sensor,idx_weight_motor));
    legend_list{k} = ['Twitch ' num2str(k)];
end
legend(legend_list)


%%
% figure;
% plot(log(abs(weights_detailed(:,idx_sensor,idx_motor))));
