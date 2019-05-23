
frequency = [0.15, 0.5, 1];
scaling = [0.2, 0.2, 0.2];
% frequency = 0.5;
direction = "X";
id_map_used = 105;
[inverse_map,sigma_advanced_coded] = get_inverse_map(direction,id_map_used);
n_limbs = size(inverse_map,1);
switch parms.n_m
    case 8
        if recordID < 103
            total_load = 16;
        else 
            total_load = 14; %cables removed
        end
     case 12
        total_load = 22.5;
    case 16
        total_load = 29;
end


GRF_term = mean(diag(inverse_map))*total_load;
sigma_advanced = scaling.*frequency*(-2*pi/GRF_term);
disp ('sigma_advanced :'); fprintf('%.4f,',sigma_advanced);
% sigma_simple = -2*pi*frequency/total_load