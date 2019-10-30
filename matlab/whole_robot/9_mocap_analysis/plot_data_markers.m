close all; clear; clc;
addpath('../2_load_data_code');
addpath(genpath('../4_locomotion'));

recordID = 302;
[data_rigidbody,data_markers_table,data_quality_table]  = load_data_mocap(recordID);
rigidbody_coordinates = read_rigidbody_marker_coordinates(recordID);

data_markers = table2array(data_markers_table);
data_quality = table2array(data_quality_table);

%%
figure;
for i_axis=1:3
    for i_marker = 1:6
        subplot(3,6,i_marker+6*(i_axis-1));
        plot(data_markers(:,i_axis+3*(i_marker-1)));
    end
end

txt_axis = {'x','y','z'};
figure;
for i_axis=1:3
    for i_marker = 1:6
        subplot(3,6,i_marker+6*(i_axis-1));
        temp = eval(strcat('data_rigidbody.',txt_axis{i_axis}));
        hold on;
        plot(data_markers(:,i_axis+3*(i_marker-1)) - temp);
        plot([1 5000],rigidbody_coordinates(i_axis+3*(i_marker-1))*[1 1],'k--');
    end
end

%%
rigid_body_pos = compute_rigid_body_pos(data_markers,data_quality,rigidbody_coordinates);

f=figure;
for i_axis=1:3
    subplot(4,1,i_axis);
    hold on;
    temp = eval(strcat('data_rigidbody.',txt_axis{i_axis}));
    plot(temp);
    plot(rigid_body_pos(:,i_axis))
    xlabel([txt_axis{i_axis} ' [m]']);
    legend('software','method');
end
subplot(4,1,4);
plot(data_rigidbody.n_markers);
linkaxes(f.Children,'x');