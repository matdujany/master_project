function new_weight = update_weight(old_weight,motor_learning,sensor_signal,parms)
nb_samples_learn = length(motor_learning);
nb_samples_theo = floor(parms.duration_part1/parms.time_interval_twitch);

if length(sensor_signal) ~= length(motor_learning)
    disp('Pb with length of motor learning signal and sensory signal');
end
if nb_samples_theo ~= nb_samples_learn
    disp('Pb with nb of samples for learning');
end

current_weight_value=old_weight;
for i=1:nb_samples_learn
    delta_weight = oja_diff_learning_rule(motor_learning(i), sensor_signal(i), current_weight_value);
    current_weight_value=current_weight_value+parms.eta*delta_weight;
end
new_weight = current_weight_value;
end