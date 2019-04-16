clear; clc;

addpath('../data');

recordID = 74;
load(strcat(get_record_name(recordID),'_p'));
add_parms;

weights_robotis = read_weights_robotis(recordID,parms);
parms_sim = parms;
parms_sim.eta = 10;
weights_sim = compute_filtered_weights_wrapper(data,lpdata,parms_sim);

weights = weights_sim;
n_iter = 5;
splitDirections = 0;
channelsSelected = [1 2 3];
renorm = 0;

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

lc_count = zeros(parms.n_lc,1);
closest_sensor = zeros(n_motors,1);
agree = zeros(n_motors,1);

nb_motors_per_loadcell = 5;

n_iter = 0;
while sum(agree)<parms.n_m && n_iter<10
    idx_lc = find(lc_count<nb_motors_per_loadcell);
    idx_motor = find(closest_sensor == 0);
    partial_sum = zeros(length(idx_lc),length(idx_motor));
    closest_sensor_tmp = zeros(n_motors,1);
    likelihood_tmp = zeros(n_motors,1);
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
    
    closest_motors = zeros(parms.n_lc,1);
    for i=1:length(idx_lc)
        [values, idx ] = maxk(partial_sum(i,:),3);
        closest_motors(idx_lc(i),1) = idx_motor(idx(1));
    end
    
    for m = 1:n_motors
        i_lc = closest_sensor_tmp(m);
        if i_lc>0 && closest_motors(i_lc,1)==m
            agree(m,1)=1;
            lc_count(i_lc,1) = lc_count(i_lc,1) + 1;
            closest_sensor(m,1) = i_lc;
        end
    end
    closest_sensor'
    n_iter=n_iter+1;
end

closest_sensor'

