function [limb,sign_direction_dropoff,sign_direction_knee] = get_good_limb(parms,recordID)
%GOOD_limb HARDCODED
switch parms.n_m
    case 8
        limb = [5     6;     7     8;     1     2;     3     4];
        sign_direction_dropoff= [1    -1    -1     1];
        sign_direction_knee = [1    -1    -1     1];
    case 12
        if recordID < 67
        limb =  [9    10;   11    12;    1     2;     7     8;     5     6;     3     4];
        sign_direction_dropoff= [1    -1    -1     1     1    -1];
        sign_direction_knee = [1   -1   -1   1  1  -1];
        else
        limb =  [9    10;   11    12;    3     4;     1     2;     7     8;     5     6];
        sign_direction_dropoff= [1    -1    -1     -1     1    1];
        sign_direction_knee = [1   -1   -1   -1  1  1];
        end
    otherwise
        disp ('unrecognized number of motors');
en
end

