function parsed_frame = parse_frame_loadcell(frame, parms)
% Get loadcell data from a frame

data_tmp = get_data_from_frame(frame, parms);

% Indices of loadcells
idx_loadcells_array = [1:length(data_tmp) - parms.IMU_data_length];

% Determine the first byte of each measurement
idx_loadcell_start = find(mod(idx_loadcells_array, parms.sensor_data_length) == 1);

    % PARSING LOADCELL DATA
    % Loop over each Arduino
    for i = 1:length(idx_loadcell_start)

        % Write to parsed_frame
        data_loadcell_tmp{i} = data_tmp(idx_loadcell_start(i):idx_loadcell_start(i)+12,:);
        i_count = 1;

        for j = 1:4:(parms.sensor_data_length - 1)
            parsed_frame{i}{i_count} = data_loadcell_tmp{i}(j:j+3,:);
            i_count = i_count + 1;
        end 

        timestamp                   = data_loadcell_tmp{i}(13,:);
        parsed_frame{i}{i_count}    = timestamp;
        
    end

end


function data_tmp = get_data_from_frame(frame, parms)
% Defining where data starts and ends in a frame

i_start_data = parms.offset_start_data;
i_end_data   = size(frame,1) - 2;

% Select correct data
data_tmp = frame(i_start_data:i_end_data,:);
end

