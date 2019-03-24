function good_locs = find_idx_twitch(data,parms)
%find_idx_twitch this function returns the frame indexes where the twitchings
%starts
%   Detailed explanation goes here
%data_findpeaks = sum(abs(data.float_value_dot_time{i_ard}),2);

data_findpeaks = 0 ;
for i = 1:parms.n_lc
    data_findpeaks = data_findpeaks + sum(abs(data.float_value_dot_time{i}),2);
end
data_findpeaks = [data_findpeaks;0];
data_findpeaks = data_findpeaks + sum(abs(data.float_value_time{parms.n_lc+1}),2);


[pks,locs] = findpeaks(data_findpeaks,'MinPeakProminence',30);

frame_between_peaks_centering = floor((parms.duration_part0+parms.duration_part2)/parms.time_interval_twitch);
frame_between_peaks_trial = floor(parms.duration_part1/parms.time_interval_twitch);

%%
confidence_margin = 0.15;
min_distance_next_peak = (1-confidence_margin)*min(frame_between_peaks_centering,frame_between_peaks_trial);
max_distance_next_peak = (1+confidence_margin)*max(frame_between_peaks_centering,frame_between_peaks_trial);

good_peaks_indexes = 1;
nb_good_peaks = 1;
current_index_raw_peaks = 2;
while (current_index_raw_peaks<=length(locs))
    %if next peak to close it is discarded
    distance_next_peak = locs(current_index_raw_peaks)-locs(good_peaks_indexes(end));
    if distance_next_peak<min_distance_next_peak
    else
        %if distance is too big we just display a warning because it is
        %strange.
        if distance_next_peak>max_distance_next_peak
            disp('Warning, the distance between 2 peaks is suspicious');
        end
        good_peaks_indexes = [good_peaks_indexes;current_index_raw_peaks];
        nb_good_peaks = nb_good_peaks + 1;       
    end
    current_index_raw_peaks = current_index_raw_peaks+1;
end
    

good_pks = pks(good_peaks_indexes);
good_locs = locs(good_peaks_indexes);
figure;
hold on;
plot(data_findpeaks);
scatter(good_locs,good_pks);
title('Summing the s-dot of loadcells and raw IMUs');
hold off;

n_peaks_theory = 2*2*parms.n_m*parms.n_twitches;

if n_peaks_theory ~= length(good_locs)
    disp('The number of found peaks is not correct');
end


end

