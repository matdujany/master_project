
function parsed_frame = parse_frame_IMU(frame, parms) 
% Get IMU Data from a frame

data_tmp = get_data_from_frame(frame, parms);

data_IMU = data_tmp(parms.nr_arduino * parms.sensor_data_length + 1: end,:);
%each data IMU should be of length 25 (4 bytes per float *6 channels + timestamp).
%in matlab, the hex will be coded as 2 char.
idx_start = [1:4:24];

for i = 1:6 % 6 channels, +3 because 4 bytes
    parsed_frame{i} = data_IMU(idx_start(i):idx_start(i)+3,:);
end

parsed_frame{7} = data_IMU(end,:); %%timestamp

end


function data_tmp = get_data_from_frame(frame, parms)
% Defining where data starts and ends in a frame

i_start_data = parms.offset_start_data;
i_end_data   = size(frame,1) - 2;

% Select correct data
data_tmp = frame(i_start_data:i_end_data,:);
end
