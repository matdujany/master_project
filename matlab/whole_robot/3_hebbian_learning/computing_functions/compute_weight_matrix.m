function weights = compute_weight_matrix(m_dot, s_dot, pos_start_learning, pos_end_learning, parms, flagReinit, weights_init)

addpath('learning_functions\');
weights = cell(parms.n_twitches,1);
n_sensors = size(s_dot,2);
for k=1:parms.n_twitches
    weights{k} = zeros(n_sensors,2*parms.n_m);
end

if nargin == 5
    flagReinit = false;
    weights_init = zeros(n_sensors,2*parms.n_m);
end

if nargin == 6
    weights_init = zeros(n_sensors,2*parms.n_m);
end

weights{1} = weights_init;

move_count=1;
for k=1:parms.n_twitches
    for i_motor = 1:parms.n_m
        for i_dir = 1:parms.n_dir
            start_learning = pos_start_learning(move_count);
            stop_learning = pos_end_learning(move_count);
            motor_learning = m_dot(start_learning:stop_learning,i_motor);
            %             if i_dir==1
            %                 motor_learning = - motor_learning;
            %             end
            for i_sensor = 1:size(s_dot,2)
                sensor_signal = s_dot(start_learning:stop_learning,i_sensor);
                old_weight = weights{k}(i_sensor,i_dir+2*(i_motor-1));
                new_weight = update_weight(old_weight,motor_learning,sensor_signal,parms);
                weights{k}(i_sensor,i_dir+2*(i_motor-1)) = new_weight;
            end
            move_count=move_count+1;
        end
    end
    
    if k<parms.n_twitches
        if ~flagReinit
            weights{k+1}=weights{k};
        else
            weights{k+1} = weights_init;
        end
    end
end

end
