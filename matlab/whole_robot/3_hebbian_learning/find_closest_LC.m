function [closest_sensor] = find_closest_LC(weights,n_iter,splitDirections,channelsSelected,parms)
%FIND_CLOSEST_LC Summary of this function goes here
%   Assumption : the closest loadcell is the one whose connection weights are the highest (in
%   absolute value)

%allChannels : (true) : all Channels of the loadcell are used to find the closest sensor.
%allChannels : (false): only the Z channel (n°3) is used.

weights_LC = weights{n_iter}(1:parms.n_lc*3,:);

if splitDirections==1
    %case 1 : the 2 dirs are split (each physical actuator is split in 2
    %virtual ones for the direction);
    n_motors = parms.n_m*2;
else
    % case 2: the 2 direction results are added (in absolute value).
    n_motors = parms.n_m;
end

lc_count = zeros(parms.n_lc,1);
closest_sensor = zeros(n_motors,1);
agree = zeros(n_motors,1);
agree_before = -1;

nb_motors_per_loadcell = 2;

n_iter = 0;
while sum(agree)<n_motors && sum(agree)>agree_before
    agree_before = sum(agree);
    idx_lc = find(lc_count<nb_motors_per_loadcell);
    idx_motor = find(closest_sensor == 0);
    
    partial_sum = zeros(length(idx_lc),length(idx_motor));
    %first, for each motor, we find the closest loadcell
    closest_sensor_tmp = zeros(n_motors,1);
    for m = 1:length(idx_motor)
        for i=1:length(idx_lc)
            ch_lc = (idx_lc(i)-1)*parms.n_ch_lc + channelsSelected;
            if splitDirections==1
                partial_sum(i,m) = sum(abs(weights_LC(ch_lc,idx_motor(m))));
            else
                partial_sum(i,m) = sum(sum(abs(weights_LC(ch_lc,1+2*(idx_motor(m)-1):2*idx_motor(m)))));
            end
            [values, idx ] = maxk(partial_sum(:,m),2);
            closest_sensor_tmp(idx_motor(m),1) = idx_lc(idx(1));
        end
    end
    %second, for each loadcell, we find the closest motor
    closest_motors = zeros(parms.n_lc,1);
    for i=1:length(idx_lc)
        [values, idx ] = maxk(partial_sum(i,:),3);
        closest_motors(idx_lc(i),1) = idx_motor(idx(1));
    end
    
    %last step, if there is an 'agreement' between loadcell and motor on
    %the closest, we put them together.
    for m = 1:n_motors
        i_lc = closest_sensor_tmp(m);
        if i_lc>0 && closest_motors(i_lc,1)==m
            agree(m,1)=1;
            lc_count(i_lc,1) = lc_count(i_lc,1) + 1;
            closest_sensor(m,1) = i_lc;
        end
    end
    n_iter=n_iter+1;
end

if sum(agree) < n_motors
    disp('Warning: some motors have no attributed loadcell');
end
end

