
n_bytes = length(data.raw);
idx_FF = find(data.raw(:,1)=='F' & data.raw(:,2)=='F');
idx_AA = find(data.raw(:,1)=='A' & data.raw(:,2)=='A');

idx_FF_AA = [];
for i=1:length(idx_FF)
    if strcmp(data.raw(idx_FF(i)+1,:),'AA')
        idx_FF_AA = [idx_FF_AA idx_FF(i)];
    end
end

temp = find(diff(idx_FF_AA)==parms.frame_size);
idx_start_frames=[];
for i=1:length(temp)
    idx_start = idx_FF_AA(temp(i));
    idx_end = idx_FF_AA(temp(i)+1);
    if (idx_end-idx_start) ~= parms.frame_size
        disp('Pb')
    end
    idx_start_frames = [idx_start_frames idx_FF_AA(temp(i))];
end

for i=1:length(idx_start_frames)
    if ~strcmp(data.raw(idx_start_frames(i)+83,:),'55')
        disp('Pb with end byte')
    end    
end

data_size = parms.nr_arduino*(3*4+1) + (6*4+1);
count_checksum_errors = 0;
for i=1:length(idx_start_frames)
    i_start_data    = idx_start_frames(i) + 5;
    data_array      = data.raw(i_start_data:i_start_data + data_size -1,:);
    checksum_calc   = dec2hex(sum(hex2dec(data_array)));
    checksum_frame  = data.raw(idx_start_frames(i) + parms.frame_size - 2,:);
    if ~strcmp(checksum_calc(end-1:end),checksum_frame)
        count_checksum_errors=count_checksum_errors+1;
    end    
end


