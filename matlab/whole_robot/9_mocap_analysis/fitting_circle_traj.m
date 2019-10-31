close all; clear; clc;
addpath('../2_load_data_code');
addpath(genpath('../4_locomotion'));
addpath('CircleFitByPratt');
addpath('InterX');

recordID = 310;

rigid_body_pos = get_rigid_body_pos(recordID);
[frame_start,frame_stop] = get_frame_start_stop(recordID);

size_mv_average = 121; %odd so it s centered
rigid_body_pos_avg = movmean(rigid_body_pos(frame_start:frame_stop,1:2),size_mv_average);

%%
figure;
hold on;
plot(rigid_body_pos(frame_start:frame_stop,1),rigid_body_pos(frame_start:frame_stop,2));
plot(rigid_body_pos_avg(:,1),rigid_body_pos_avg(:,2));
legend('raw','mv avg');

%%
% [speed_circle,circle_fit] = fit_circle_wrapper(rigid_body_pos(frame_start:frame_stop,1:2),true);
[speed_circle,circle_fit] = fit_circle_wrapper(rigid_body_pos_avg,true);



