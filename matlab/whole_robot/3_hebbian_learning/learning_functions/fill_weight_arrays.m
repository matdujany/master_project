function weights = fill_weight_arrays(s_dot_for_learning,parms)
%FILL_WEIGHT_ARRAYS Summary of this function goes here
%   Detailed explanation goes here

weights = cell(parms.n_twitches,1);
for k=1:parms.n_twitches
    weights{k}=zeros(parms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU, parms.n_m * parms.n_dir);
end

motor_step_unit = 1; % always assumed to be 1
% 1st step
for index_motor = 0:parms.n_m-1
    for index_dir = 1:2 %actually representing -1 and then  1
        for index_sensor = 1:parms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU
            s_dot_learning = s_dot_for_learning{1}(index_sensor,index_dir+2*index_motor);
            delta_weight = oja_diff_learning_rule(motor_step_unit, s_dot_learning, 0);
            weights{1}(index_sensor,index_dir+2*index_motor) = 0 + parms.eta*delta_weight;
        end
    end
end

for k=2:parms.n_twitches
    for index_motor = 0:parms.n_m-1
        for index_dir = 1:2 %actually representing -1 and then  1
            for index_sensor = 1:parms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU
                s_dot_learning = s_dot_for_learning{k}(index_sensor,index_dir+2*index_motor);
                weight_learning = weights{k-1}(index_sensor,index_dir+2*index_motor);
                delta_weight = oja_diff_learning_rule(motor_step_unit, s_dot_learning, weight_learning);
                weights{k}(index_sensor,index_dir+2*index_motor) = weight_learning + parms.eta*delta_weight;
            end
        end
    end
end


end

