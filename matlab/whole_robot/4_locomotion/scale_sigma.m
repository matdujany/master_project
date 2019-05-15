
% frequency = [0.25, 0.5, 1, 1.5];
frequency = 0.5;
direction = "Y";
id_map_used = 86;
[inverse_map,sigma_advanced_coded] = get_inverse_map(direction,id_map_used);
n_limbs = size(inverse_map,1);
switch n_limbs
    case 4
        total_load = 16;
     case 6
        total_load = 22.5;
    case 8
        total_load = 29;
end



GRF_term = mean(diag(inverse_map))*total_load;
sigma_advanced = 0.5*-2*pi*frequency/GRF_term
% sigma_simple = -2*pi*frequency/total_load