function [limb,sign_direction_dropoff,sign_direction_knee] = get_good_limb(parms,recordID)
%GOOD_limb HARDCODED
switch parms.n_m
    case 6
            limb = [5     6;     3      4;     1     2];
            sign_direction_dropoff= 0;
            sign_direction_knee = 0;
    case 8
        if recordID < 67
            limb = [5     6;     7     8;     1     2;     3     4];
            sign_direction_dropoff= [1    -1    -1     1];
            sign_direction_knee = [1    -1    -1     1];
        else
            sign_direction_dropoff=0;
            sign_direction_knee = 0;
            if recordID < 103
                limb = [1    5;     4     6;     2     3;     7     8];

            else
                if recordID < 115
                    limb = [5    6;     3       4;     1     2;     7     8];
                else
                    limb = [3    1;    5    6;   2       4;    7     8];
                end
            end
        end
    case 12
        if recordID < 67
        limb =  [9    10;   11    12;    1     2;     7     8;     5     6;     3     4];
        sign_direction_dropoff= [1    -1    -1     1     1    -1];
        sign_direction_knee = [1   -1   -1   1  1  -1];
        else
            if recordID <107
                limb =  [9    10;   11    12;    3     4;     1     2;     7     8;     5     6];
                sign_direction_dropoff= [1    -1    -1     -1     1    1];
                sign_direction_knee = [1   -1   -1   -1  1  1];
            else
                limb =  [9    10;   1    7;    4     5;     2     3;     6     8;     11     12];
                sign_direction_dropoff= 0;
                sign_direction_knee =0   ;
            end
        end
    case 16
        limb =  [13    14;   15    16;    4     5;     2     3;     9     1;     8     10; 11 12; 6 7];   
        sign_direction_dropoff= 0;
        sign_direction_knee = 0;
        if recordID == 94
            limb =  [9    1;   8    10;    4     5;     2     3;     13     14;     15     16; 11 12; 6 7];   
        end
        if recordID >= 111
            limb =  [13    14;     9     1;     6     7;    12    11;     2     3;     4     5;     8    10;    15    16];
        end
    otherwise
        disp ('unrecognized number of motors');
end

