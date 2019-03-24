recordID = 26;
load(strcat(get_record_name(recordID),'_p'));
add_parms;
allChannels =1 ;
n_iter=5;
weights = read_weights_robotis_2(recordID,parms);


closest_sensor = zeros(parms.n_m,1);
partial_sums = zeros(parms.n_lc,parms.n_m);
for m = 1:parms.n_m
    for i=1:parms.n_lc
        if allChannels==1
            ch_lc = 1+(i-1)*parms.n_ch_lc:i*parms.n_ch_lc;
        else
            ch_lc = 3*i;
        end
        partial_sums(i,m) = sum(sum(abs(weights{n_iter}(ch_lc,1+2*(m-1):2*m))));
    end
    [values, idx ] = maxk(partial_sums(:,m),2);
    closest_sensor(m) = idx(1);
    likelihood(m) = values(1)/values(2);
end

%% 
%after this first pass, we count the number 
closest_sensor
nb_motors_loadcell = zeros(parms.n_lc,1);
for m = 1:parms.n_m
    nb_motors_loadcell(closest_sensor(m))=nb_motors_loadcell(closest_sensor(m))+1;
end
count_trials = 0;
while sum(abs(nb_motors_loadcell-2*ones(parms.n_lc,1)))>0 && count_trials < 50
    [~,idx_sensor_too_filled]=max(nb_motors_loadcell);
    idx_motors = find(closest_sensor==idx_sensor_too_filled);
    [~,pos_min] = min(likelihood(idx_motors));
    idx_motor_to_move = idx_motors(pos_min);
    [values, idx ] = maxk(partial_sums(:,idx_motor_to_move),parms.n_lc);
    i=1;
    while idx(i)==idx_sensor_too_filled
        i=i+1;
    end
    disp(['Motor ' num2str(idx_motor_to_move) ...
        ' moved from sensor ' num2str(closest_sensor(idx_motor_to_move))...
        ' to sensor ' num2str(idx(i))]);
    closest_sensor(idx_motor_to_move) = idx(i);
    if idx(i)==1
        likelihood(idx_motor_to_move) = values(idx(i))/values(2);
    else
        likelihood(idx_motor_to_move) = values(idx(i))/values(1);
    end 
    closest_sensor
    count_trials = count_trials + 1;
    nb_motors_loadcell = zeros(parms.n_lc,1);
    for m = 1:parms.n_m
        nb_motors_loadcell(closest_sensor(m))=nb_motors_loadcell(closest_sensor(m))+1;
    end
end

