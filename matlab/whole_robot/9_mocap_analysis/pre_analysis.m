%this is to plot the data and then handpick the start frame and stop frame (for speed
%analysis) and the frames where the software reconstructed weirdly the
%rigidbody (cf 302 303 304) and function correct_weird_points

close all; clear; clc;
addpath('../2_load_data_code');
addpath(genpath('../4_locomotion'));

recordID = 311;
[data_rigidbody,data_markers_table,data_quality_table]  = load_data_mocap(recordID);
rigidbody_coordinates = read_rigidbody_marker_coordinates(recordID);

data_markers = table2array(data_markers_table);
data_quality = table2array(data_quality_table);

%% showing data markers
figure;
for i_axis=1:3
    for i_marker = 1:6
        subplot(3,6,i_marker+6*(i_axis-1));
        plot(data_markers(:,i_axis+3*(i_marker-1)));
    end
end

% txt_axis = {'x','y','z'};
% figure;
% for i_axis=1:3
%     for i_marker = 1:6
%         subplot(3,6,i_marker+6*(i_axis-1));
%         temp = eval(strcat('data_rigidbody.',txt_axis{i_axis}));
%         hold on;
%         plot(data_markers(:,i_axis+3*(i_marker-1)) - temp);
%         plot([1 5000],rigidbody_coordinates(i_axis+3*(i_marker-1))*[1 1],'k--');
%     end
% end

%% demonstrating that the recomputation method works 
rigid_body_pos_all_recomputed = compute_rigid_body_pos(data_markers,data_quality,rigidbody_coordinates);

txt_axis = {'x','y','z'};
f=figure;
for i_axis=1:3
    subplot(4,1,i_axis);
    hold on;
    software_data = eval(strcat('data_rigidbody.',txt_axis{i_axis}));
    plot(software_data);
    plot(rigid_body_pos_all_recomputed(:,i_axis))
    xlabel([txt_axis{i_axis} ' [m]']);
    legend('software','all recomputed');
end
subplot(4,1,4);
plot(data_rigidbody.n_markers);
linkaxes(f.Children,'x');

%% showing the correction on the weird points
rigid_body_pos = table2array(data_rigidbody(:,4:6));
rigidbody_marker_coordinates = read_rigidbody_marker_coordinates(recordID);
rigid_body_pos = correct_weird_points(recordID,rigid_body_pos,data_markers,data_quality,rigidbody_marker_coordinates);
rigid_body_pos = rigid_body_pos(:,[1 3 2]);

[frame_start,frame_stop] = get_frame_start_stop(recordID);

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
    rigid_body_pos(frame_start:frame_stop,2));
xlabel('X direction [m]');
ylabel('Y direction [m]');
axis equal;
title('software data corrected');