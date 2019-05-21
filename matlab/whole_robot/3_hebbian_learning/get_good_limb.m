function [limb,sign_direction_dropoff,sign_direction_knee] = get_good_limb(parms,recordID)
%GOOD_limb HARDCODED
switch parms.n_m
    case 8
        if recordID < 67
            limb = [5     6;     7     8;     1     2;     3     4];
            sign_direction_dropoff= [1    -1    -1     1];
            sign_direction_knee = [1    -1    -1     1];
        else
            limb = [1    5;     4     6;     2     3;     7     8];
            sign_direction_dropoff=0;
            sign_direction_knee = 0;
        end
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
    case 16
        limb =  [13    14;   15    16;    4     5;     2     3;     9     1;     8     10; 11 12; 6 7];   
        sign_direction_dropoff= 0;
        sign_direction_knee = 0;
        if recordID == 94
            limb =  [9    1;   8    10;    4     5;     2     3;     13     14;     15     16; 11 12; 6 7];   
        end
    otherwise
        disp ('unrecognized number of motors');
en
end

