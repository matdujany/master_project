%% ROBOTIS - MATLAB ANALYSIS
%  data_processing.m
clear; clc; close all;

addpath('functions');
addpath('../2_load_data_code');
%% loading.
recordID = 155;
n_limb = 6;
phi_only = false;

fprintf("data_processing\n");
filename = get_record_name_locomotion(recordID);
[data_rec, phi_position_data, parms_locomotion, parms] = load_data_locomotion(recordID);

% parms.n_m = 8;
% parms.nr_arduino = 4;
% parms.n_lc = 4;
% parms.frame_size  = 7 + parms.nr_arduino * parms.sensor_data_length + parms.IMU_data_length;
fprintf('Data loaded from file: %s\n', filename);

%% Main 

% % % DATA STRUCT % % %
% Initialize data struct
data                = struct();
data.frame          = {};
data.raw            = [];
data.count_frames   = 0;
% Process recorded data
data.raw                 = dec2hex(data_rec);

% Parse data stream / detect frames
data                    = parse_datastream(data, parms);
        
% Parsing frames
frameparser_wrapper     = @(frame_array) parse_frame_wrapper(frame_array, parms) ;
data.parsed_frame       = cellfun(frameparser_wrapper, data.frame, 'UniformOutput', false) ;

% Convert to float values
convert_wrapper                             = @(parsed_frame_array) convert_to_float_wrapper(parsed_frame_array, parms) ;
data.float_value_frame                      = cellfun(convert_wrapper, data.parsed_frame, 'UniformOutput', false) ;     % Data ordered per frame

% Parse to time arrays
data.float_value_time = data_per_loadcell(data, parms);                                          % Data ordered per Arduino
data.float_value_time{parms.nr_arduino+1}   = data_of_IMU(data, parms);

% Parse time stamps
for i = 1:size(data.frame,1)
    for j=1:parms.nr_arduino
        %for the Arduino we take the 4th value, the 3 before are the
        %loadcell values
        data.timestamp_hex{i,j} = data.parsed_frame{i}{j}{4};
    end
    %for the IMU we take the 7th value because 6 channels before 
    data.timestamp_hex{i,parms.nr_arduino+1} = data.parsed_frame{i}{parms.nr_arduino+1}{7};

end

data.time = parse_timestamps(data, parms);

%using the timestamps, we compute the differential values of the loadcells
for i=1:parms.nr_arduino
    data.float_value_dot_time{i} = 10^3*diff(data.float_value_time{i})./diff(data.time(:,i));
    data.float_value_dot_time{1,i}=[zeros(1,3);data.float_value_dot_time{1,i}];
end

%% pos and phi data 
parms.n_limb = n_limb;
if phi_only == true
    pos_phi_data = parsing_phi_data_locomotion(phi_position_data,parms);
else
    pos_phi_data = parsing_pos_phi_data_locomotion(phi_position_data,parms);
end

%%
if data.count_frames ~= size(pos_phi_data.phi_update_timestamp,2)
     disp('Warning ! The number of frames from the loadcells and from the motor positions do not match');
end

%%
file_name_processed_data=strcat("../../../../data/locomotion/",filename,'_p');
fprintf("Writing processed data to file: %s.mat\n", file_name_processed_data);
save(file_name_processed_data,'data','pos_phi_data','parms_locomotion','parms');

%% Functions 


function parsed_frame = parse_frame_wrapper(frame, parms)
% Frame parser wrapper

parsed_frame        = parse_frame_loadcell(frame, parms);
parsed_frame{end+1} = parse_frame_IMU(frame, parms);

end


function float_value = convert_char_array(parsed_frame, parms)
% Convert hexadecimal string into float

% Concatenate characters
hex_string  = strcat(parsed_frame(4,:),parsed_frame(3,:),parsed_frame(2,:),parsed_frame(1,:));

% Convert to float
float_value = typecast(uint32(hex2dec(hex_string)),'single');
 
end

function float_value_frame = convert_to_float_wrapper(parsed_frame, parms)
% Convert to float wrapper

float_value_frame           = convert_to_float_loadcells(parsed_frame, parms);
float_value_frame{end+1}    = convert_to_float_IMU(parsed_frame, parms);

end

function float_value_frame = convert_to_float_loadcells(parsed_frame, parms)


% Loop over all Arduino's
for i = 1:parms.nr_arduino
    
    % Loop over all sensors
    for j = 1:3
        
        % Select data
        arr_tmp = parsed_frame{i}{j};

        % Convert the character array to a float
        float_value_frame{i}(j)  = convert_char_array(arr_tmp);
    end
end

end

function float_value_frame = convert_to_float_IMU(parsed_frame, parms)

for i = 1:length(parsed_frame{end})-1 %-1 because timestamp
   float_value_frame(i) = convert_char_array(parsed_frame{parms.nr_arduino + 1}{i});
end

end






function float_values_ard = data_per_loadcell(data, parms)
% Get float values from loadcell datas

for i_ard = 1:parms.nr_arduino
    
    % Number of frames
    n_frames = size(data.float_value_frame,1);
    
    % Initialize matrix
    float_values_ard{i_ard} = zeros(n_frames,3);
    
    % Fill in data
    for i_step = 1:n_frames
        float_values_ard{i_ard}(i_step,:) = [data.float_value_frame{i_step}{i_ard}];
    end
        
end

end

function float_values_IMU = data_of_IMU(data, parms)
% Get float values from IMU data

% Number of frames
n_frames = size(data.float_value_frame,1);

% Initialize matrix
float_values_IMU = zeros(n_frames,6);

% Fill in data
for i_step = 1:n_frames
    float_values_IMU(i_step,:) = data.float_value_frame{i_step}{parms.nr_arduino+1};
end

end



