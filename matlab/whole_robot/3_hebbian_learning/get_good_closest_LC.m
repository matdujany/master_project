function good_closest_LC = get_good_closest_LC(parms,recordID)
%GOOD_CLOSEST_LC HARDCODED
switch parms.n_m
    case 6
        good_closest_LC = [3;3;1;1;2;2];      
    case 8
        if recordID < 100
            good_closest_LC = [3;3;4;4;1;1;2;2];
        end
        if ismember(recordID,[100:102])
            good_closest_LC = [1;3;3;2;1;2;4;4];
        end        
        if ismember(recordID,[103:105 128:129])
           good_closest_LC = [3;3;2;2;1;1;4;4]; % 4legs_6
        end
        if ismember(recordID,[116:127])
           good_closest_LC = [1;3;1;3;2;2;4;4]; %4 legs weird
        end
    case 12
        if recordID < 67
            good_closest_LC = [3;3;6;6;5;5;4;4;1;1;2;2];
        end
        if ismember(recordID,[68:91])
                good_closest_LC = [4;4;3;3;6;6;5;5;1;1;2;2];
        end
        if ismember(recordID,[107:110 138:140])
           good_closest_LC = [2;4;4;3;3;5;2;5;1;1;6;6];
        end
        if ismember(recordID,[130:130])
           good_closest_LC = [6;4;4;2;2;3;6;3;1;1;5;5];
        end
        if ismember(recordID,[131:132])
           good_closest_LC = [5;1;1;3;3;2;5;2;4;4;6;6];
        end
        if ismember(recordID,[134:137])
           good_closest_LC = [6;4;4;2;2;3;6;3;1;1;5;5];
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

