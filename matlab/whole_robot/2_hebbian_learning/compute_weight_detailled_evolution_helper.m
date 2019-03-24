function weights = compute_weight_detailled_evolution_helper(m_dot, s_dot, eta, weights_init)
% weights is nblearningSamples,n_sensors
% m_dot is nblearningSamples x 1
% s_dot is nblearningSamples x nbSensors
% weights init is 1xnbSensors


addpath('learning_functions\');
if length(m_dot) ~= size(s_dot,1)
    disp('Problem with m_dot and s_dot dimensions');
    return;
end

nblearningSamples = size(s_dot,1);
n_sensors = size(s_dot,2);
weights = zeros(nblearningSamples,n_sensors);

if nargin == 3
    weights_init = zeros(1,n_sensors);
end

previous_weight_values = weights_init;
for k=1:nblearningSamples
    for i_sensor = 1:n_sensors
        delta_weight = oja_diff_learning_rule(m_dot(k,1), s_dot(k,i_sensor), previous_weight_values(1,i_sensor));
        weights(k,i_sensor) =  previous_weight_values(1,i_sensor)+eta*delta_weight;
    end
    previous_weight_values = weights(k,:);
end
end




