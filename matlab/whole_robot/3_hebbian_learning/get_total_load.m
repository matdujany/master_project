function total_load = get_total_load(recordID,parms)

switch parms.n_m
    case 8
        if recordID < 103
            total_load = 16;
        else 
            if recordID < 116
                total_load = 14; %cables removed
            else
                total_load = 12;%cables removed and weird configurations
            end
        end
     case 12
        if recordID < 107
            total_load = 22.5;
        else 
            total_load = 19.2; %cables removed
        end
    case 16
        if recordID < 111
            total_load = 29;
        else 
            total_load = 25.2; %cables removed
        end        
end