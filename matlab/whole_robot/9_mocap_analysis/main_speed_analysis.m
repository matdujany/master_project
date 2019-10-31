close all; clear; clc;
addpath('../2_load_data_code');
addpath(genpath('../4_locomotion'));
addpath('curvature');
addpath('CircleFitByPratt');
addpath('InterX');

recordID = 310;
rigid_body_pos = get_rigid_body_pos(recordID);
[frame_start,frame_stop] = get_frame_start_stop(recordID);
%%
size_mv_average = 121; %odd so it s centered
rigid_body_pos_avg = movmean(rigid_body_pos(frame_start:frame_stop,1:2),size_mv_average);

%%
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
% n_samples_GRF = size(data.time,1);
% n_limb = size(data.time,2)-1;
% 
% phi = pos_phi_data.limb_phi;
% delta_phases = compute_delta_phases(phi);
% time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
% [f_delta_phases,ax_delta_phases] = plot_delta_phases(time,delta_phases,recordID);
% 
% GRF = zeros(n_samples_GRF,n_limb);
% GRP = zeros(n_samples_GRF,n_limb);
% for i=1:n_limb
%     GRF(:,i) = data.float_value_time{1,i}(:,3);
%     GRP(:,i) = data.float_value_time{1,i}(:,2);
% end
% 
% figure;
% plot(sum(GRF,2));

%%
figure;
hold on;
plot(rigid_body_pos(frame_start:frame_stop,1),rigid_body_pos(frame_start:frame_stop,2));
plot(rigid_body_pos_avg(:,1),rigid_body_pos_avg(:,2));
legend('raw','mv avg');
xlabel('X direction [m]');
ylabel('Y direction [m]');

%%
distance_curve = compute_curve_distance(rigid_body_pos_avg);
distance_straight = sqrt(sum((rigid_body_pos_avg(end,:)-rigid_body_pos_avg(1,:)).^2));
distance_forward = sqrt((rigid_body_pos_avg(end,2)-rigid_body_pos_avg(1,2))^2);

speed_curve = distance_curve/((frame_stop-frame_start)/120);
speed_forward = distance_forward/((frame_stop-frame_start)/120);

cycle_duration = 1/parms_locomotion.frequency * 120; 
n_cycles = floor((frame_stop-frame_start)/cycle_duration);
distance_curve_cycles = zeros(n_cycles,1);
speed_curve_cycles = zeros(n_cycles,1);
for i=1:n_cycles
    frame_start_cycle = 1 +(i-1)*cycle_duration;
    frame_end_cycle = frame_start_cycle+cycle_duration;
    distance_curve_cycles(i,1) = compute_curve_distance(rigid_body_pos_avg(frame_start_cycle:frame_end_cycle,:));
    speed_curve_cycles(i,1) = distance_curve_cycles(i,1)/((frame_end_cycle-frame_start_cycle)/120);
end

figure;
hold on;
plot(speed_curve_cycles);
plot([0 20],speed_curve*[1 1],'r');
plot([0 20],mean(speed_curve_cycles)*[1 1],'k--');
xlabel('Cycle index');
ylabel('Speed [m/s]');

%%
[speed_circle,circle_fit] = fit_circle_wrapper(rigid_body_pos_avg,true);



