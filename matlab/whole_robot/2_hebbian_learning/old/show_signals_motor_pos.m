clear; 
close all; clc;

addpath('learning_functions');
addpath('../data');

recordID = 73;
load(strcat(get_record_name(recordID),'_p'));

i_lc = 3;
figure;
for channel=1:3
    subplot(2,2,channel);
    hold on;
    for i_motor=1:parms.n_m
        plot((lpdata.motor_position(i_motor,:)-512)/30);
    end
    yyaxis right;
    plot(data.float_value_dot_time{1,i_lc}(:,channel));
end

%%
figure;
for channel=1:3
    subplot(2,2,channel);
    hold on;
    plot(lpdata.last_motor_pos);
    ylim([470 550]);
    yyaxis right;
    plot(data.float_value_time{1,i_lc}(:,channel));
end

%%
n_frames_part0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_part2 = floor(parms.duration_part2/parms.time_interval_twitch);

nb_theo_frames = (n_frames_part0+n_frames_part1+n_frames_part2)*(parms.n_twitches*parms.n_m*parms.n_dir);



