n_frames_p0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_p1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_p2 = floor(parms.duration_part2/parms.time_interval_twitch);

n_frames_arr = [n_frames_p0 n_frames_p1 n_frames_p2];
actual_durations = cell(3,1);

start_index = 1;
current_value = i_part(start_index);
moving_index = 2;
while (moving_index<length(i_part))
    if i_part(moving_index) == current_value
        moving_index=moving_index+1;
    else
        actual_durations{current_value+1,1}(end+1) = moving_index-start_index;
        start_index = moving_index;
        current_value = i_part(start_index);
        moving_index = moving_index+1;
    end
end
