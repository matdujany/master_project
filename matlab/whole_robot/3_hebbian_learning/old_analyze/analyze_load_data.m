%this is to analyze roughly load recorded during
%twitch experiment)
clear; 
close all; clc;

addpath('../2_load_data_code');

%% Load data
recordID = 88;
[data, lpdata, parms] =  load_data_processed(recordID);

%%
n_frames_theo = get_theo_number_frames(parms);

motor_loads = zeros(2*n_frames_theo.per_action,parms.n_m,parms.n_twitches);
for k = 1:parms.n_twitches
    index_start_twitch = 1+n_frames_theo.per_twitch*(k-1);
    for i_motor = 1:parms.n_m
        index_start_motor = index_start_twitch+n_frames_theo.per_action*2*(i_motor-1);
        index_end_motor = index_start_motor+2*n_frames_theo.per_action-1;
        motor_loads(:,i_motor,k) = lpdata.motor_load(i_motor,index_start_motor:index_end_motor);
    end
end

theoretical_traj = [compute_theoretical_traj_wrapper(1,parms) 512*ones(1,n_frames_theo.part2)...
    compute_theoretical_traj_wrapper(2,parms) 512*ones(1,n_frames_theo.part2)];

%% just 1 motor
idx_motor_plot = 4;
figure;
hold on;
for k=1:parms.n_twitches
    plot(motor_loads(:,idx_motor_plot,k));
end
ylabel('Load');
xlabel('Sample index');
title(['M' num2str(idx_motor_plot)]);
yyaxis right;
plot(theoretical_traj,'k--');
ylim(512+60*[-1 1]);
ylabel('Ramp to follow');

%% all motors in subplots
figure;
indexes_plot = reshape(1:parms.n_m, 4, 2).';
for i_motor=1:parms.n_m
    subplot(2,4,indexes_plot(i_motor));
    hold on;
    for k=1:parms.n_twitches
        plot(motor_loads(:,i_motor,k));
    end
    ylabel('Load');
    xlabel('Sample index');
    title(['M' num2str(i_motor)]);
    ylim(500*[-1 1]);
    yyaxis right;
    plot(theoretical_traj,'k--');
    ylim(512+60*[-1 1]);
    ylabel('Ramp to follow');
end

%% all motors average on one plot
figure;
hold on;
legend_list = cell(parms.n_m,1);
for i_motor=1:parms.n_m
    hold on;
    plot(mean(motor_loads(:,i_motor,:),3));
    ylabel('Position');
    xlabel('Sample index');
    legend_list{i_motor}=(['M' num2str(i_motor)]);
    ylim(500*[-1 1]);
end
legend(legend_list);
yyaxis right;
plot(theoretical_traj,'k--','HandleVisibility','off');
ylim(512+60*[-1 1]);
ylabel('Ramp to follow');

