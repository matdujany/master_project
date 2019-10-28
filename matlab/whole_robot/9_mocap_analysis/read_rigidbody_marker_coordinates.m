function rigidbody_marker_coordinates = read_rigidbody_marker_coordinates(recordID)
%LOAD_DATA_MOCAP Summary of this function goes here
%   Detailed explanation goes here


take_name = get_take_name(recordID);

currentFolder = pwd;
cd('../../../../motion_capture_data/');

rigidbody_marker_coordinates = xlsread(take_name,'E45:V45');

cd(currentFolder);


end

