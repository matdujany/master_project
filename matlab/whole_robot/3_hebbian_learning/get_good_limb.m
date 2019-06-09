function limb = get_good_limb(parms,recordID)
%GOOD_limb HARDCODED
switch parms.n_m
    case 6
            limb = [5     6;     3      4;     1     2];
    case 8
        if recordID < 103
            limb = [1    5;     4     6;     2     3;     7     8];
        end
        if ismember(recordID,[103:105 128:129])
            limb = [5    6;     3       4;     1     2;     7     8];
        end
        if ismember(recordID,[116:127])
            limb = [3    1;    5    6;   2       4;    7     8];
        end
    case 12
        if recordID < 67
            limb =  [9    10;   11    12;    1     2;     7     8;     5     6;     3     4];
        end
         if ismember(recordID,[68:91])
            limb =  [9    10;   11    12;    3     4;     1     2;     7     8;     5     6];
        end
        if ismember(recordID,[107:110])
            limb =  [9    10;   7    1;    4     5;     2     3;     6     8;     11     12];
        end
        if ismember(recordID,[130:130])
            limb =  [9    10;   4    5;    6     8;     2     3;     11     12;     7     1];
        end
        if ismember(recordID,[131:132])
            limb =  [2    3;   6     8;     4     5;     9  10;     7     1; 11     12];
        end
    case 16
        limb =  [13    14;   15    16;    4     5;     2     3;     9     1;     8     10; 11 12; 6 7];   
        if recordID == 94
            limb =  [9    1;   8    10;    4     5;     2     3;     13     14;     15     16; 11 12; 6 7];   
        end
        if recordID >= 111
            limb =  [13    14;     9     1;     6     7;    12    11;     2     3;     4     5;     8    10;    15    16];
        end
    otherwise
        disp ('unrecognized number of motors');
end

