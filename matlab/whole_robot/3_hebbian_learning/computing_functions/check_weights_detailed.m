function [diff_norm_lc, diff_norm_IMU]= check_weights_detailed(weights_detailed,weights_robotis,parms)
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);

if size(weights_detailed,1) ~= n_frames_part1 * parms.n_twitches
    disp('Problem! The size of weights detailed is not correct');
    return
end

diff_norm_lc = zeros(parms.n_twitches,1);
diff_norm_IMU = zeros(parms.n_twitches,1);

for k=1:parms.n_twitches
    diff_norm_lc(k) = sum(sum(abs(weights_robotis{k,1}(1:3*parms.n_lc,:)-squeeze(weights_detailed(k*n_frames_part1,1:3*parms.n_lc,:)))));
    diff_norm_IMU(k) = sum(sum(abs(weights_robotis{k,1}(3*parms.n_lc+1:end,:)-squeeze(weights_detailed(k*n_frames_part1,3*parms.n_lc+1:end,:)))));
end

end

