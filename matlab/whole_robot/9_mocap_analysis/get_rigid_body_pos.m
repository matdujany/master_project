function rigid_body_pos = get_rigid_body_pos(recordID)
%GET_RIGID_BODY_POS Summary of this function goes here
%   Detailed explanation goes here
[data_rigidbody,data_markers_table,data_quality_table]  = load_data_mocap(recordID);
rigidbody_marker_coordinates = read_rigidbody_marker_coordinates(recordID);

data_markers = table2array(data_markers_table);
data_quality = table2array(data_quality_table);

rigid_body_pos = table2array(data_rigidbody(:,4:6));
rigid_body_pos = correct_weird_points(recordID,rigid_body_pos,data_markers,data_quality,rigidbody_marker_coordinates);
rigid_body_pos = rigid_body_pos(:,[1 3 2]);

end

