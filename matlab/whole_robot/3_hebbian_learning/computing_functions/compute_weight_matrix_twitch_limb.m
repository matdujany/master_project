function weights = compute_weight_matrix_twitch_limb(m_s_dot_pos, s_dot, pos_start_learning, pos_end_learning, parms, flagReinit, weights_init)

limb = get_good_limb(parms,138);

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
    for i_limb = 1:parms.n_limb
        for i_dir = 1:parms.n_dir
            start_learning = pos_start_learning(move_count);
            stop_learning = pos_end_learning(move_count);
            for i_servo_limb = 1:2
                i_motor = limb(i_limb,i_servo_limb);
                motor_learning = m_s_dot_pos(start_learning:stop_learning,i_motor);
                for i_sensor = 1:size(s_dot,2)
                    sensor_signal = s_dot(start_learning:stop_learning,i_sensor);
                    old_weight = weights{k}(i_sensor,i_dir+2*(i_motor-1));
                    new_weight = update_weight(old_weight,motor_learning,sensor_signal,parms);
                    weights{k}(i_sensor,i_dir+2*(i_motor-1)) = new_weight;
                end
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
