function good_closest_LC = get_good_closest_LC(parms,recordID)
%GOOD_CLOSEST_LC HARDCODED
switch parms.n_m
    case 8
        good_closest_LC = [3;3;4;4;1;1;2;2];
    case 12
        if recordID < 67
            good_closest_LC = [3;3;6;6;5;5;4;4;1;1;2;2];
        else
            good_closest_LC = [4;4;3;3;6;6;5;5;1;1;2;2];
        end
    case 16
        good_closest_LC = [5;4;4;3;3;8;8;6;5;6;7;7;1;1;2;2];
        if recordID == 94
            good_closest_LC = [1;4;4;3;3;8;8;2;1;2;7;7;5;5;6;6];
        end
    otherwise
        disp('unrecognized number of motors');
end

end

