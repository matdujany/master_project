function [data_rigidbody,data_markers,data_quality] = load_data_mocap(recordID)
%LOAD_DATA_MOCAP Summary of this function goes here
%   Detailed explanation goes here


take_name = get_take_name(recordID);
disp(['Loading motion capture data from ' take_name]);
currentFolder = pwd;
cd('../../../../motion_capture_data/');

data=readtable(take_name,'Delimiter',',','HeaderLines',45,'Comment','rigidbody');
data_rigidbody=data(:,[2,3,4,6:8,13:16]);
data_rigidbody.Properties.VariableNames = {'FrameID','time','detectionStatus','x','y','z','yaw',' pitch', 'roll','n_markers'};

data_markers = data(:,[17:19,22:24,27:29,32:34,37:39,42:44]);
data_markers.Properties.VariableNames = {'x1','y1','z1','x2','y2','z2','x3','y3','z3','x4','y4','z4','x5','y5','z5','x6','y6','z6'};

supp_data=readtable(take_name,'Delimiter',',','HeaderLines',45,'Comment','frame');

data_quality=supp_data(:,[56:62]);
data_quality.Properties.VariableNames = {'Marker1','Marker2',' Marker3', 'Marker4','Marker5','Marker6','mean_error'};

cd(currentFolder);


end

