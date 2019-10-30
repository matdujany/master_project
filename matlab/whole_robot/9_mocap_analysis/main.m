close all; clear; clc;
addpath('../2_load_data_code');
addpath(genpath('../4_locomotion'));

recordID = 319;
[data_rigidbody,data_markers_table,data_quality_table]  = load_data_mocap(recordID);
rigidbody_marker_coordinates = read_rigidbody_marker_coordinates(recordID);

data_markers = table2array(data_markers_table);
data_quality = table2array(data_quality_table);

rigid_body_pos = table2array(data_rigidbody(:,4:6));
rigid_body_pos = correct_weird_points(recordID,rigid_body_pos,data_markers,data_quality,rigidbody_marker_coordinates);

time_Mocap = data_rigidbody.time; %120 fps, mocap resolution

%%
[frame_start,frame_stop] = get_frame_start_stop(recordID);

txt_axis = {'x','y','z'};
f=figure;
for i_axis=1:3
    subplot(4,1,i_axis);
    hold on;
    temp = eval(strcat('data_rigidbody.',txt_axis{i_axis}));
    plot(temp);
    plot(rigid_body_pos(:,i_axis))
    xlabel([txt_axis{i_axis} ' [m]']);
    plot(frame_start*[1 1],[0 3],'k--');
    plot(frame_stop*[1 1],[0 3],'k--');
    legend('software','after correction with method');
end
subplot(4,1,4);
plot(data_rigidbody.n_markers);
linkaxes(f.Children,'x');

idx_pb = find(data_rigidbody.n_markers(frame_start:frame_stop)<6);

%%

figure;
subplot(1,2,1);
plot(data_rigidbody.x(frame_start:frame_stop),...
    data_rigidbody.z(frame_start:frame_stop));
xlabel('X direction [m]');
ylabel('Y direction [m]');
axis equal;
title('software');
subplot(1,2,2);
plot(rigid_body_pos(frame_start:frame_stop,1),...
    rigid_body_pos(frame_start:frame_stop,3));
xlabel('X direction [m]');
ylabel('Y direction [m]');
axis equal;
title('software data corrected');

%%

[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
n_samples_GRF = size(data.time,1);
n_limb = size(data.time,2)-1;

phi = pos_phi_data.limb_phi;
delta_phases = compute_delta_phases(phi);
time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
[f_delta_phases,ax_delta_phases] = plot_delta_phases(time,delta_phases,recordID);

GRF = zeros(n_samples_GRF,n_limb);
GRP = zeros(n_samples_GRF,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end

figure;
plot(sum(GRF,2));

