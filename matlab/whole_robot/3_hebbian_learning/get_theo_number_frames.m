function n_frames_theo = get_theo_number_frames(parms)
%GET_THEO_NUMBER_FRAMES Summary of this function goes here
%   Detailed explanation goes here
n_frames_theo.part0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_theo.part1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_theo.part2 = floor(parms.duration_part2/parms.time_interval_twitch);

n_frames_theo.per_action = n_frames_theo.part0+n_frames_theo.part1+n_frames_theo.part2;

n_frames_theo.per_twitch = n_frames_theo.per_action*(parms.n_m*parms.n_dir);

end

