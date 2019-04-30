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
    otherwise
        disp('unrecognized number of motors');
end

end

