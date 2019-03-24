function n_byte_approx = predict_n_bytes_approximate(parms)
n_moves = parms.n_twitches * parms.n_m * parms.n_dir;
n_frames_p0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_p1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_p2 = floor(parms.duration_part2/parms.time_interval_twitch);
n_frames_approx = n_moves*(n_frames_p0+n_frames_p1+n_frames_p2);

n_byte_approx = (parms.frame_size * n_frames_approx)*1.1;