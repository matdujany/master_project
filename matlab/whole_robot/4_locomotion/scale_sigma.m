
n_motors = 16;

frequency = [0.25, 0.5, 1, 1.5];
switch n_motors
    case 8
        total_load = 16;
     case 12
        total_load = 22.5;
    case 16
        total_load = 29;
end

direction = "X";
id_map_used = 94;
[inverse_map,sigma_advanced_coded] = get_inverse_map(direction,id_map_used);

GRF_term = mean(diag(inverse_map))*total_load;
sigma_advanced = -2*pi*frequency/GRF_term;
sigma_simple = -2*pi*frequency/total_load