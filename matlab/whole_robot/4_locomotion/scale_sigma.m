
frequency = [0.15, 0.5, 1];
scaling = [0.5, 0.5, 0.5];
% scaling = 0.5;
% frequency = 0.5;
direction = "X";
recordid_map_used = 127;
[inverse_map,sigma_advanced_coded] = get_inverse_map(direction,recordid_map_used);

rand_map=[
[0.05, -0.36, -0.35, -0.24]
[0.34, -0.25, 0.31, -0.26]
[0.43, -0.15, -0.30, -0.25]
[0.12, -0.03, -0.15, 0.33]
];
% inverse_map = rand_map;

n_limbs = size(inverse_map,1);

switch 2*n_limbs
    case 8
        if recordid_map_used < 103
            total_load = 16;
        else
            if recordid_map_used < 116
                total_load = 14; %cables removed
            else
                total_load = 12;%cables removed and weird configurations
            end
        end
    case 12
        if recordid_map_used < 107
            total_load = 22.5;
        else
            total_load = 19.2;%cables removed
        end
    case 16
        if recordid_map_used < 110
            total_load = 29;
        else
            total_load = 25.2;
        end
        
end


GRF_term = mean(abs(diag(inverse_map)))*total_load;
sigma_advanced = scaling.*frequency*(2*pi/GRF_term);
sigma_simple = scaling.*frequency*(-2*pi/total_load);
disp ('sigma_advanced :'); fprintf('%.4f,',sigma_advanced);
% sigma_simple = -2*pi*frequency/total_load