close all; clear; clc;
addpath('../2_load_data_code');
addpath(genpath('../4_locomotion'));
addpath('curvature');
addpath('CircleFitByPratt');
addpath('InterX');

recordID = 311
rigid_body_pos = get_rigid_body_pos(recordID);
[frame_start,frame_stop] = get_frame_start_stop(recordID);
%%
size_mv_average = 121; %odd so it s centered
rigid_body_pos_avg = movmean(rigid_body_pos(:,1:3),size_mv_average);

txt_axis = {'x','y','z'};
figure;
for i=1:3
    subplot(3,1,i)
plot(rigid_body_pos_avg(:,i));
xlabel([txt_axis{i} ' direction [m]']);
end

%%
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
n_samples_GRF = size(data.time,1);
n_limb = size(data.time,2)-1;
n_samples_phi = size(pos_phi_data.limb_phi,2);

GRF = zeros(n_samples_GRF,n_limb);
GRP = zeros(n_samples_GRF,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end

figure;
plot(sum(GRF,2));

%%
frame_liftoff_mocap = 8250;
frame_liftoff_GRF = 2710;

time_Mocap = ((1:size(rigid_body_pos_avg,1)) - frame_liftoff_mocap)/120;
time_GRF = ((1:n_samples_GRF) - frame_liftoff_GRF)/40;
time_phi = (pos_phi_data.phi_update_timestamp(1,:) - pos_phi_data.phi_update_timestamp(1,frame_liftoff_GRF))/10^3;

phi = pos_phi_data.limb_phi;
delta_phases = compute_delta_phases(phi);
[f_delta_phases,ax_delta_phases] = plot_delta_phases(time_phi,delta_phases,recordID);


txt_axis = {'x','y','z'};
figure;
for i=1:3
    subplot(3,1,i)
plot(time_Mocap,rigid_body_pos_avg(:,i));
xlabel([txt_axis{i} ' direction [m]']);
end
