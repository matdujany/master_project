clear; 
close all; clc;

addpath('learning_functions');
addpath('../data');
addpath('../plotting_functions');

% warning('off')

%% Load data

recordID = 5;
load(strcat(get_record_name(recordID),'_p'));

add_parms

%%

if 0
for i_ard=1:parms.nr_arduino
    plot_LC_data(i_ard, data)
    plot_LC_dot_data(i_ard, data)
end
end

%%
i_ard = 1;
direction = 1;
time_part = data.time(:,i_ard);
data_part = data.float_value_time{i_ard}(:,direction);
data_dot_part = data.float_value_dot_time{i_ard}(:,direction);

data_findpeaks = 0 ;
for i = 1:parms.n_lc
    data_findpeaks = data_findpeaks + sum(abs(data.float_value_dot_time{i}),2);
end
data_findpeaks = [data_findpeaks;0];
data_findpeaks = data_findpeaks + sum(abs(data.float_value_time{parms.n_lc+1}),2);

%%
n_moves = 2*2*parms.n_m*parms.n_twitches;
%show_peaks(data_part,1);
%show_peaks(data_dot_part,50);
show_peaks(data_findpeaks,20);


%%
[pks,locs] = findpeaks(data_findpeaks,'MinPeakProminence',20);

duration_part0 = 500;
duration_part1 = 2000;
duration_part2 = 1000;
time_interval_twitch = 36;

frame_between_peaks_centering = floor((duration_part0+duration_part2)/time_interval_twitch);
frame_between_peaks_trial = floor(duration_part1/time_interval_twitch);

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
hold off;
    
%%

function show_peaks(values,minpeakprom)
[pks,locs] = findpeaks(values,'MinPeakProminence',minpeakprom);

figure;
hold on;
plot(values);
scatter(locs,pks);
hold off;
end

