function good_closest_LC = get_good_closest_LC(parms,recordID)
%GOOD_CLOSEST_LC HARDCODED
switch parms.n_m
    case 6
        good_closest_LC = [3;3;1;1;2;2];      
    case 8
        if recordID < 100
            good_closest_LC = [3;3;4;4;1;1;2;2];
        else
            if recordID < 103
                good_closest_LC = [1;3;3;2;1;2;4;4];
            else
                if recordID < 115
                    good_closest_LC = [3;3;2;2;1;1;4;4];
                else
                    good_closest_LC = [1;3;1;3;2;2;4;4];
                end
            end
        end
    case 12
        if recordID < 67
            good_closest_LC = [3;3;6;6;5;5;4;4;1;1;2;2];
        else
            if recordID <107
                good_closest_LC = [4;4;3;3;6;6;5;5;1;1;2;2];
            else
                good_closest_LC = [2;4;4;3;3;5;2;5;1;1;6;6];
            end
        end
    case 16
        good_closest_LC = [5;4;4;3;3;8;8;6;5;6;7;7;1;1;2;2];
        if recordID == 94
            good_closest_LC = [1;4;4;3;3;8;8;2;1;2;7;7;5;5;6;6];
        end
        if recordID >= 111
           good_closest_LC = [2;5;5;6;6;3;3;7;2;7;4;4;1;1;8;8];
        end
    otherwise
        disp('unrecognized number of motors');
end

end

