%% ROBOTIS - MATLAB ANALYSIS
%  data_processing.m
% 
%  DESCRIPTION: 
%  Processes the data, meaning parsing, converting byte values into doubles
%  and doing some checks.
%  
%  TO DO:
%  - Write checksum function to verify that data transfer succeeded without
%    errors
% 
%  NOTES:
%  There is a dozen of parsing functions, which basically can be divided
%  into two categories: 1) parsing functions that help to convert the raw
%  data into a set of frames and 2) parsing the data in every one of these
%  frames to get the loadcell and IMU data (among others). 

%% Initializing stuff

addpath('functions')

clear; clc; close all;

recordID = 94;

% Check if there is already an instance of a communication interface and
% clears it
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

%% loading
addpath('../2_load_data_code');
fprintf("data_processing\n");
filename = get_record_name(recordID);
[data_rec, pos_load_data_rec, parms] = load_data_raw(recordID);
fprintf('Data loaded from file: %s\n', filename);
IMU_offsets = true;
gyro_in_degs = true;

%% Main 
n_moves = parms.n_twitches * parms.n_m * parms.n_dir;
n_frames_p0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_p1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_p2 = floor(parms.duration_part2/parms.time_interval_twitch);
n_frames_theo = n_moves*(n_frames_p0+n_frames_p1+n_frames_p2);
disp(['theoretical number of learning frames (given parms file) : ' num2str(n_frames_theo)]);

lpdata = parsing_load_and_pos_data(pos_load_data_rec,parms);
disp(['Parsed load and pos data, ' num2str(length(lpdata.i_part)) ' frames found']);

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

if sum(size(data.frame)) == 0
   fprintf("Parser found no frames, are you sure the settings in set_parms are correct?\n");  
   return
end

if data.count_frames > n_frames_theo
    disp('The number of frames found is > to the theoretical number of frames');
    disp('This could be due to the frames used to count arduinos (in particular if n_arduinos = MAX_NR_ARDUINO)');
    n_frames_delete = data.count_frames - n_frames_theo;
    prompt = ['Do you want to remove the ' num2str(n_frames_delete) ' first lines (y/n)? '];
    answer = input(prompt,'s');
    if answer == 'y'
        disp(['Deleting ' num2str(n_frames_delete) ' first lines']);
        data.count_frames = data.count_frames - n_frames_delete;
        data.frame = data.frame(1+n_frames_delete:end);
    else
        prompt = ['Do you want to remove the ' num2str(n_frames_delete) ' last lines (y/n)? '];
        answer = input(prompt,'s');
        if answer == 'y'
            data.count_frames = data.count_frames - n_frames_delete;
            data.frame = data.frame(1:end-n_frames_delete);
        end
    end
end
        
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

%% if IMU offsets, we correct that
if IMU_offsets
    parms.IMU_offsets = true;
    IMU_offsets = read_IMU_offsets(recordID,parms.n_twitches);
    n_frames_twitch_cycle =  parms.n_m * parms.n_dir * (n_frames_p0+n_frames_p1+n_frames_p2);
    data.IMU_corrected = zeros(size(data.float_value_time{1,parms.nr_arduino+1}));
    if size(data.float_value_time{1,parms.nr_arduino+1},2)~=6
        disp('Warning, not 6 IMU channels ?');
    end
    if size(data.float_value_time{1,parms.nr_arduino+1},1)~=n_frames_theo
        disp('Not theoretical number of frames in IMU data');
    end
    for k=1:parms.n_twitches
        data_IMU = data.float_value_time{1,parms.nr_arduino+1}(1+(k-1)*n_frames_twitch_cycle:k*n_frames_twitch_cycle,:);
        data.IMU_corrected(1+(k-1)*n_frames_twitch_cycle:k*n_frames_twitch_cycle,:) = ...
            data_IMU - IMU_offsets(k,:);
    end
end

%% gyro correction
gyro_gain = 0.06957;
if gyro_in_degs
    parms.gyro_in_rads = true;
    data_gyro = data.IMU_corrected(:,4:6);
    data_gyro_corrected = data_gyro*gyro_gain;
    data.IMU_corrected(:,4:6) = data_gyro_corrected;
end

%%
file_name_processed_data=strcat("../../../../data/",filename,'_p');
fprintf("Writing processed data to file: %s.mat\n", file_name_processed_data);
save(file_name_processed_data,'data','lpdata','parms');

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



