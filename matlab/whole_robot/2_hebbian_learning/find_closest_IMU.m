function sorted_actuators = find_closest_IMU(weights,n_iter,splitDirections,allChannels,parms)
%FIND_CLOSEST_IMU this is to find the motors which have the stronger
%connections to IMU
%   Detailed explanation goes here

%allChannels : (true) : all Channels of the IMU are used to find the
%closest motors (4 channels, X Y Z and yaw)
%allChannels : (false): only the Z channel (n°3) is used.

if splitDirections ==1
    if allChannels==1
        weights_IMU_sum_splitDir = sum(abs(weights{n_iter}(end-parms.n_useful_ch_IMU:end,:)),1);
    else
        weights_IMU_sum_splitDir = abs(weights{n_iter}(end-1,:));
    end
    [~, sorted_actuators] = sort(weights_IMU_sum_splitDir,'descend');
else
    weights_IMU_sum_fusedDir = zeros(parms.n_m,1);
    for m=1:parms.n_m
        index_motor = 1+(m-1)*parms.n_dir:parms.n_dir*m;
        if allChannels == 1
            weights_IMU_sum_fusedDir(m) = sum(sum(abs(weights{n_iter}(end-parms.n_useful_ch_IMU:end,index_motor))));
        else
            weights_IMU_sum_fusedDir(m) = sum(sum(abs(weights{n_iter}(end-1,index_motor))));
        end
    end
    [~, sorted_actuators] = sort(weights_IMU_sum_fusedDir,'descend');
end

end

