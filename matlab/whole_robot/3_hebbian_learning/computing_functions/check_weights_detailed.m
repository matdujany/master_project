function diff_norm= check_weights_detailed(weights_detailed,weights_robotis,parms)
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);

if size(weights_detailed,1) ~= n_frames_part1 * parms.n_twitches
    disp('Problem! The size of weights detailed is not correct');
    return
end

diff_norm = zeros(parms.n_twitches,1);
for k=1:parms.n_twitches
    diff_norm(k) = sum(sum(abs(weights_robotis{k,1}-squeeze(weights_detailed(k*n_frames_part1,:,:)))));
end

end

