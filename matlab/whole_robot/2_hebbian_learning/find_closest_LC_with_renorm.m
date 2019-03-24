clear; clc;

addpath('../data');

recordID = 61;
load(strcat(get_record_name(recordID),'_p'));
add_parms;

weights = read_weights_robotis(recordID,parms);n_iter = 5;
splitDirections = 0;
channelsSelected = [1 2 3];
renorm = 2;

weights_LC = weights{n_iter}(1:parms.n_lc*3,:);
switch renorm
    case 1
        %the columns (motor action) now sum to 1 : 
        weights_LC = weights_LC./sum(weights_LC,1);
    case 2
        %the lines (sensor response) now sum to 1 : 
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
closest_sensor'