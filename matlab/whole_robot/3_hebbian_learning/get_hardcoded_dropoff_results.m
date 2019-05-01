function [motor_ids_dropoff,sign_direction_dropoff]= get_hardcoded_dropoff_results(parms)
switch parms.n_m
    case 8
        motor_ids_dropoff = [5     7     1     3];
        sign_direction_dropoff= [1    -1    -1     1];
    case 12
        motor_ids_dropoff =  [9     11    3    1     7    5];
        sign_direction_dropoff= [1    -1    -1     -1     1    1];
    otherwise
        disp ('unrecognized number of motors');
en
end