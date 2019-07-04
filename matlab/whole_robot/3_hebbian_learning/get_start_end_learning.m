function [pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,flagPlot)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
n_frames_part0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_part2 = floor(parms.duration_part2/parms.time_interval_twitch);

if isfield(parms,'twitch_limb') &&  parms.twitch_limb== 1
    n_moving_blocks = parms.n_limb;
else
    n_moving_blocks = parms.n_m ;
end


% nb_theo_frames = (n_frames_part0+n_frames_part1+n_frames_part2)*(parms.n_twitches*n_moving_blocks*parms.n_dir);
% changes_frame = [n_frames_part0 n_frames_part0+n_frames_part1 n_frames_part0+n_frames_part1+n_frames_part2];

total_duration = n_frames_part0+n_frames_part1+n_frames_part2;

pos_start_learning = [n_frames_part0+1];
pos_end_learning   = [n_frames_part0+n_frames_part1];

for k=1:parms.n_twitches
    for i_moving = 1:n_moving_blocks
        for i_dir = 1:parms.n_dir
            pos_start_learning=[pos_start_learning pos_start_learning(end)+total_duration];
            pos_end_learning=[pos_end_learning pos_end_learning(end)+total_duration];
        end
    end
end
pos_start_learning(end)=[];
pos_end_learning(end)=[];

%%
if isfield(parms,'step_ampl')
    ylims = 512+parms.step_ampl*4*[-1 1];
else
    ylims = [470 550];
end

if flagPlot
figure;
hold on;
for i=1:length(pos_start_learning) 
    plot([pos_start_learning(i) pos_start_learning(i)],[470 550],'b--');
    plot([pos_end_learning(i) pos_end_learning(i)],[470 550],'r--');
end
for i=1:parms.n_m
    plot(lpdata.motor_position(i,:));
end
ylim(ylims);

figure;
hold on;
for i=1:parms.n_m
    plot(lpdata.motor_position(i,:));
end
ylim(ylims);

figure;
hold on;
for i=1:parms.n_m
    plot(lpdata.motor_load(i,:));
end
end

if data.count_frames~=length(lpdata.i_part)
    disp('The number of frames found by Matlab in the Daisychain does not match the one found by openCM');
end

end

