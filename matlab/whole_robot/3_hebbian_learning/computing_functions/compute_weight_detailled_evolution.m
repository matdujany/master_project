function weights = compute_weight_detailled_evolution(m_dot, s_dot, pos_start_learning, pos_end_learning, parms, flagReinit,weights_init)
% weights is nblearningSamples,n_sensors,2*parms.n_m
% weights_init is n_sensors,2*parms.n_m
addpath('learning_functions\');

n_sensors = size(s_dot,2);

n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
nblearningSamples = n_frames_part1 * parms.n_twitches;

weights = zeros(nblearningSamples,n_sensors,2*parms.n_m);

if nargin == 5
    flagReinit = false;
    weights_init = zeros(n_sensors,2*parms.n_m);
end

if nargin == 6
    weights_init = zeros(n_sensors,2*parms.n_m);
end

previous_weights_values = weights_init;
move_count=1;
for k=1:parms.n_twitches
    for i_motor = 1:parms.n_m
        for i_dir = 1:parms.n_dir
            start_learning = pos_start_learning(move_count);
            stop_learning = pos_end_learning(move_count);
            motor_learning = m_dot(start_learning:stop_learning);
%             if i_dir==1
%                 motor_learning = - motor_learning;
%             end
            sensor_signal = s_dot(start_learning:stop_learning,:); 
            weights_init_part = previous_weights_values(:,i_dir+parms.n_dir*(i_motor-1))';
            weights_part = compute_weight_detailled_evolution_helper(motor_learning, sensor_signal, parms.eta, weights_init_part);
            weights(1+n_frames_part1*(k-1):k*n_frames_part1,:,i_dir+parms.n_dir*(i_motor-1)) = weights_part;
            move_count = move_count + 1;
        end
    end
    if ~flagReinit
        previous_weights_values(:,:) = weights(k*n_frames_part1,:,:);
    end
end
end

