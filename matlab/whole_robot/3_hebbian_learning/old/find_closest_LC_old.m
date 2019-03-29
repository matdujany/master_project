function [closest_sensor,likelihood] = find_closest_LC(weights,n_iter,splitDirections,channelsSelected,renorm,refine,parms)
%FIND_CLOSEST_LC Summary of this function goes here
%   Assumption : the closest loadcell is the one whose connection weights are the highest (in
%   absolute value)

%allChannels : (true) : all Channels of the loadcell are used to find the closest sensor.
%allChannels : (false): only the Z channel (n°3) is used.

weights_LC = weights{n_iter}(1:parms.n_lc*3,:);
if renorm==1
    weights_LC = weights_LC./sum(weights_LC,2);
end

if splitDirections==1
    %case 1 : the 2 dirs are split (each physical actuator is split in 2
    %virtual ones for the direction);
    n_motors = parms.n_m*2;
else
    % case 2: the 2 direction results are added (in absolute value).
    n_motors = parms.n_m;
end

closest_sensor = zeros(n_motors,1);
likelihood = zeros(n_motors,1);
partial_sum = zeros(parms.n_lc,n_motors);
for m = 1:n_motors
    for i=1:parms.n_lc
        ch_lc = (i-1)*parms.n_ch_lc + channelsSelected;
        if splitDirections==1
            partial_sum(i,m) = sum(abs(weights_LC(ch_lc,m)));
        else
            partial_sum(i,m) = sum(sum(abs(weights_LC(ch_lc,1+2*(m-1):2*m))));
        end
        [values, idx ] = maxk(partial_sum(:,m),2);
        closest_sensor(m) = idx(1);
        likelihood(m) = values(1)/values(2);
    end
end

%%reaffining to balance the number of motors per loadcell.
if refine == 1
    nb_motors_loadcell = zeros(parms.n_lc,1);
    for m = 1:n_motors
        nb_motors_loadcell(closest_sensor(m))=nb_motors_loadcell(closest_sensor(m))+1;
    end
    count_trials = 0;
    while sum(abs(nb_motors_loadcell-2*ones(parms.n_lc,1)))>0 && count_trials < 50
        [~,idx_sensor_too_filled]=max(nb_motors_loadcell);
        idx_motors = find(closest_sensor==idx_sensor_too_filled);
        [~,pos_min] = min(likelihood(idx_motors));
        idx_motor_to_move = idx_motors(pos_min);
        [values, idx ] = maxk(partial_sum(:,idx_motor_to_move),parms.n_lc);
        i=1;
        while idx(i)==idx_sensor_too_filled
            i=i+1;
        end
        %disp(['Motor ' num2str(idx_motor_to_move) ...
        %    ' moved from sensor ' num2str(closest_sensor(idx_motor_to_move))...
        %    ' to sensor ' num2str(idx(i))]);
        closest_sensor(idx_motor_to_move) = idx(i);
        if idx(i)==1
            likelihood(idx_motor_to_move) = values(idx(i))/values(2);
        else
            likelihood(idx_motor_to_move) = values(idx(i))/values(1);
        end
        count_trials = count_trials + 1;
        nb_motors_loadcell = zeros(parms.n_lc,1);
        for m = 1:n_motors
            nb_motors_loadcell(closest_sensor(m))=nb_motors_loadcell(closest_sensor(m))+1;
        end
    end
end
end

