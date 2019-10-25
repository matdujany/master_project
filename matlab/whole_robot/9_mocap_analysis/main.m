close all; clear; clc;

filename = 'Take 2019-10-24 04.31.49 PM.csv';

data=readtable(filename,'Delimiter',',','HeaderLines',45,'Comment','rigidbody');
data=data(:,[2,3,4,6:8,13:16]);
data.Properties.VariableNames = {'FrameID','time','detectionStatus','x','y','z','yaw',' pitch', 'roll','n_markers'};

data_quality=readtable(filename,'Delimiter',',','HeaderLines',45,'Comment','frame');
data_quality=data_quality(:,[56:62]);
data_quality.Properties.VariableNames = {'Marker1','Marker2',' Marker3', 'Marker4','Marker5','Marker6','mean_error'};

%%
origin_x = mean(data.x(1:100));
origin_z = mean(data.z(1:100));
data.x = data.x - origin_x;
data.z = data.z - origin_z;

time_Mocap 

%%
figure;
subplot(3,1,1);
plot(data.x);
xlabel('X [m]');
subplot(3,1,2);
plot(data.y);
xlabel('Y [m] (altitude)');
subplot(3,1,3);
plot(data.z);
xlabel('Z [m]');

%%
frame_start = 1000;
frame_stop = 7200;
figure;
plot(data.x(1:frame_stop),data.z(1:frame_stop));
xlabel('X direction [m]');
ylabel('Y direction [m]');
xlim([-0.1 0.1]);