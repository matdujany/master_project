function s_dot_for_learning = fill_s_dot_learning_matrix(data,parms,idx_moves,flagPlot)
%FILL_S_DOT_LEARNING_MATRIX Summary of this function goes here
%   Detailed explanation goes here

% Creating s and s_dot matrix
s_dot_lc = zeros(data.count_frames-1,parms.n_lc * parms.n_ch_lc);
%-1 because the diff makes us lose 1 frame.
for i=1:parms.n_lc
    s_dot_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_dot_time{i};
end
s_dot_lc = [s_dot_lc;zeros(1,parms.n_lc * parms.n_ch_lc)]; %just adding a line of zeros

s_IMU = data.float_value_time{3}; %we dont diff the IMUS.
s_lc = zeros(data.count_frames,parms.n_lc * parms.n_ch_lc);
for i=1:parms.n_lc
    s_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_time{i};
end

% Initialize s_dot_for_learning 
s_dot_for_learning = cell(parms.n_twitches,1);
for k=1:parms.n_twitches
    s_dot_for_learning{k}=zeros(parms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU, parms.n_m * parms.n_dir);
end

% TODO: USELESS, check with Simon
% epoch           = 0;           % Initialize epoch counter
% epoch_max       = 1;           % Number of epochs
% range_select    = 10;          % This will be the size of s_dot_select (and thus the number of samples that will be used for learning)

duration_part0_frame = floor(parms.duration_part0/parms.time_interval_twitch);   % no margin
duration_part1_frame = floor(parms.duration_part1/parms.time_interval_twitch)-5; % no margin

move_count=1;
for k=1:parms.n_twitches
    for index_motor = 0:parms.n_m-1
        for index_dir = 1:2 %actually representing -1 and then  1
            
            index_frame_beginning_part0 = idx_moves(move_count)-duration_part0_frame;
            index_frame_end_part1 = idx_moves(move_count)+duration_part1_frame;            
            
            %part 1 is supposed to stop before the return to initial
            %position (called part2 in robotis code).
            if index_frame_end_part1>idx_moves(move_count+1)
                disp('Pb with timing: part 1 ends after peak of going back to initial pos');
            end
            
            s_lc_temp = s_lc(index_frame_beginning_part0:index_frame_end_part1,:);            
            s_dot_lc_temp = s_dot_lc(index_frame_beginning_part0:index_frame_end_part1,:);
            s_IMU_temp = s_IMU(index_frame_beginning_part0:index_frame_end_part1,:);

            pos_peak = duration_part0_frame;
            
            temp_values = analyze_twitch_result_wrapper(s_lc_temp,s_dot_lc_temp,s_IMU_temp,pos_peak,parms,flagPlot);
            
            s_dot_for_learning{k}(:,index_dir+2*index_motor)=temp_values';
            
            move_count=move_count+2; %incrementing by 2 to skip the move caused by the returning to 0 after each twitching
        end
    end
    
end


end

