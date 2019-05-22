

clear;
close all; clc;

addpath('hinton_plot_functions');
addpath('computing_functions');
addpath('../2_load_data_code');
addpath('../../tight_subplot');


%% Load data
recordID = 102;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);

neutral_pos = read_neutral_pos(recordID,parms.n_m);

%% compare motor to motor actual movement.

idx_twitch = 1;
i_motor = 2;

n_frames_theo = get_theo_number_frames(parms);

index_start_twitch = 1+n_frames_theo.per_twitch*(idx_twitch-1);
index_start_motor = index_start_twitch+n_frames_theo.per_action*2*(i_motor-1);
index_end_motor = index_start_motor+2*n_frames_theo.per_action-1;


%%
motor_move = zeros(2*n_frames_theo.per_action,parms.n_m,parms.n_twitches);
for k = 1:parms.n_twitches
    index_start_twitch = 1+n_frames_theo.per_twitch*(k-1);
    for i_motor = 1:parms.n_m
        index_start_motor = index_start_twitch+n_frames_theo.per_action*2*(i_motor-1);
        index_end_motor = index_start_motor+2*n_frames_theo.per_action-1;
        motor_move(:,i_motor,k) = lpdata.motor_position(i_motor,index_start_motor:index_end_motor)-neutral_pos(i_motor);
    end
end



theoretical_traj = compute_theoretical_traj_wrapper(1,parms);
for i=1:n_frames_theo.part2
    last_motor_pos = lpdata.motor_position(i_motor,index_start_motor+n_frames_theo.part0+n_frames_theo.part1+i-1);
    theoretical_traj(1,n_frames_theo.part0+n_frames_theo.part1+i) = ...
        512 + floor((last_motor_pos-512)*(1-i/n_frames_theo.part2));
end
theoretical_traj = [theoretical_traj compute_theoretical_traj_wrapper(2,parms)];
for i=1:n_frames_theo.part2
    last_motor_pos = lpdata.motor_position(i_motor,index_start_motor+n_frames_theo.per_action+n_frames_theo.part0+n_frames_theo.part1+i-1);
    theoretical_traj(1,n_frames_theo.per_action+n_frames_theo.part0+n_frames_theo.part1+i) = ...
        512 + floor((last_motor_pos-512)*(1-i/n_frames_theo.part2));
end
theoretical_traj = theoretical_traj -512;

%% just 1 motor
idx_motor_plot = 4;
figure;
hold on;
for k=1:parms.n_twitches
    plot(motor_move(:,idx_motor_plot,k));
end
plot(theoretical_traj);
ylabel('Position');
xlabel('Sample index');
title(['M' num2str(idx_motor_plot)]);

%% all motors in subplots
figure;
n_rows = parms.n_m/4;
indexes_plot = reshape(1:parms.n_m, 4, n_rows).';
for i_motor=1:parms.n_m
    subplot(n_rows,4,indexes_plot(i_motor));
    hold on;
    plot(theoretical_traj,'k--');
    for k=1:parms.n_twitches
        plot(motor_move(:,i_motor,k));
    end
    ylabel('Position');
    xlabel('Sample index');
    title(['M' num2str(i_motor)]);
    ylim(60*[-1 1]);
end

%% all motors average on one plot
figure;
hold on;
legend_list = cell(parms.n_m,1);
for i_motor=1:parms.n_m
    hold on;
    plot(mean(motor_move(:,i_motor,:),3));
    ylabel('Position');
    xlabel('Sample index');
    legend_list{i_motor}=(['M' num2str(i_motor)]);
    ylim(60*[-1 1]);
end
plot(theoretical_traj,'k--');
legend_list{end+1} = 'Theoretical trajectory';
legend(legend_list);

%%
recentering_own_movement = zeros(2*parms.n_m,parms.n_twitches);
peak_neg = zeros(parms.n_m,parms.n_twitches);
peak_pos = zeros(parms.n_m,parms.n_twitches);

for i_motor=1:parms.n_m
    recentering_own_movement(2*i_motor-1,:) = mean(motor_move(1:n_frames_theo.part0,i_motor,:),1);
    recentering_own_movement(2*i_motor,:) = mean(motor_move(n_frames_theo.per_action+[1:n_frames_theo.part0],i_motor,:),1);  
    peak_neg(i_motor,:) = motor_move(n_frames_theo.part0+n_frames_theo.part1,i_motor,:);
    peak_pos(i_motor,:) = motor_move(n_frames_theo.per_action+n_frames_theo.part0+n_frames_theo.part1,i_motor,:);
end


%%
plot_erorrbar_static_mean(mean(recentering_own_movement,2),std(recentering_own_movement,[],2),0,parms,'Recentering after own movement static mean')
plot_erorrbar_peaks(mean(peak_neg,2),std(peak_neg,[],2),min(theoretical_traj),parms,'Negative peak (learning)')
plot_erorrbar_peaks(mean(peak_pos,2),std(peak_pos,[],2),max(theoretical_traj),parms,'Positive peak (learning)')

%%
position_before_action = zeros(parms.n_m,parms.n_twitches*2*parms.n_m);
count = 0;
for k = 1:parms.n_twitches
    index_start_twitch = 1+n_frames_theo.per_twitch*(k-1);
    for i_action = 1:2*parms.n_m
        count = count+1;
        index_start_action = index_start_twitch+n_frames_theo.per_action*(i_action-1);
        index_end_action = index_start_action + n_frames_theo.part0-1;
        for i_motor = 1:parms.n_m
            position_before_action(i_motor,count) = mean(lpdata.motor_position(i_motor,index_start_action:index_end_action));
        end
    end
end

figure;
hold on;
color_array = lines(parms.n_m/2);
for i_motor = 1:parms.n_m
    linestyle = '-';
    if mod(i_motor,2) == 0
        linestyle = '--';
    end
    plot(position_before_action(i_motor,:),'LineStyle',linestyle,'Color',color_array(ceil(i_motor/2),:));
end
legend(cellstr(num2str([1:parms.n_m]')));
xlabel('Action count');
ylabel('Motor Position');
title('Motor recentering before each action');

%%
recentering_before_action_split = reshape(position_before_action,[parms.n_m,2*parms.n_m,parms.n_twitches]);
recentering_before_action_split_mean = mean(recentering_before_action_split,3);
recentering_before_action_split_std = std(recentering_before_action_split,[],3);
figure;
hold on;
color_array = lines(parms.n_m/2);
for i_motor = 1:parms.n_m
    linestyle = '-';
    if mod(i_motor,2) == 0
        linestyle = '--';
    end
    errorbar(recentering_before_action_split_mean(i_motor,:),recentering_before_action_split_std(i_motor,:),...
        'LineStyle',linestyle,'Color',color_array(ceil(i_motor/2),:));
end
legend(cellstr(num2str([1:parms.n_m]')));
xlabel('Action count');
ylabel('Motor Position');
title('Motor recentering before each action, averaged over the twitches');

function plot_erorrbar_static_mean(mean_errbar,std_errbar, objective_value,parms,titleString)
figure;
hold on;
errorbar(mean_errbar,std_errbar,'o');
plot([1 parms.n_m*2],[objective_value objective_value],'k--');
ax=gca();
for i_motor=1:parms.n_m
    plot(2*i_motor+0.5+[0 0],ax.YLim,'k--');
end
x_tick_label_list = cell(2*parms.n_m,1);
for i_motor=1:parms.n_m
    x_tick_label_list{2*i_motor-1,1} = ['M' num2str(i_motor) '-'];
    x_tick_label_list{2*i_motor,1} = ['M' num2str(i_motor) '+'];
end
xticks([1:parms.n_m*2]);
xticklabels(x_tick_label_list)
title(titleString);
end

function plot_erorrbar_peaks(mean_errbar,std_errbar, objective_value,parms,titleString)
figure;
hold on;
errorbar(mean_errbar,std_errbar,'o');
plot([1 parms.n_m],[objective_value objective_value],'k--');
x_tick_label_list = cell(parms.n_m,1);
for i_motor=1:parms.n_m
    x_tick_label_list{i_motor,1} = ['M' num2str(i_motor)];
end
xticks([1:parms.n_m]);
xticklabels(x_tick_label_list)
title(titleString);
end