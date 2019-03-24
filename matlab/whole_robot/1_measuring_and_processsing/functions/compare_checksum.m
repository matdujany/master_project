function bool_frame = compare_checksum(data, parms)
% Compare checksums as calculated from the data and the one obtained from the
% frame

    % Calculate checksum given the recorded data
    data_size       = parms.idx_end_data - parms.offset_start_data;
    i_start_data    = data.last_byte_index - parms.frame_size + parms.offset_start_data;
    data_array      = data.raw(i_start_data:i_start_data + data_size,:);
    checksum_calc   = dec2hex(sum(hex2dec(data_array)));
    
    % Obtain checksum from frame
    checksum_frame  = data.raw(i_start_data + data_size + 1,:);

    % Compare checksums and return boolean
    bool_frame = strcmp(checksum_calc(end-1:end),checksum_frame);
    
end