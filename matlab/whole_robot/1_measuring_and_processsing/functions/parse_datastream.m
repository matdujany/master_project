function data = parse_datastream(data, parms)
% Main function for parsing

fprintf('Parse data stream\n')

n_data = length(data.raw);

% i_FirstStartByte = find(data == 'FF')

for idx = 1:length(data.raw)
    data.last_byte          = data.raw(idx,:);
    data.last_byte_index    = idx;
    [bool_frame, ~]         = check_frame(data, parms);
    
    
    if(bool_frame)
        
        % Count number of detected frames
        data.count_frames = data.count_frames + 1;
        
        % At the moment that bool_frame == 1, idx has the value of the
        % end byte. It needs to go back (frame_size - 1) indices to arrive
        % at the first start byte or (frame_size - 6) indices to arrive at
        % the first data byte.
        idx_tmp = (idx + 1) - parms.frame_size:idx;
        
        % Writing the identified frame to the data struct.
        data.frame(data.count_frames,1) = {data.raw( idx_tmp,:)} ;
       
    end
end


fprintf("%i frames found!\n", data.count_frames)


end
