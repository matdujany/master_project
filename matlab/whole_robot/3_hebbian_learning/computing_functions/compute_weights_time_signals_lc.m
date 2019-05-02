function weights = compute_weights_time_signals_lc(data,lpdata,parms,flagFilter,flagPlot,flagDetailed,flagReinit,weights_init)
%compute_weights_wrapper Summary of this function goes here
%   Detailed explanation goes here

[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,flagPlot);

%% Creating s matrix
if flagFilter == 1 || (isfield(parms,'use_filter') && parms.use_filter == 1)
    disp('using filtered data');
    data = compute_filtered_signal_data(data,parms);
    sensor_values = data.s_lc_filtered;
    [m_dot_values,~]  = compute_mdot_learning(data,lpdata,parms,1);
else
    s_lc = zeros(data.count_frames,parms.n_lc * parms.n_ch_lc);
    for i=1:parms.n_lc
        s_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_time{i};
    end
    sensor_values = s_lc;
    [m_dot_values,~]  = compute_mdot_learning(data,lpdata,parms,0);
end

if nargin == 7
    n_sensors = size(sensor_values,2);
    weights_init = zeros(n_sensors,2*parms.n_m);
end

if flagDetailed==1
    weights = compute_weight_detailled_evolution(m_dot_values, sensor_values, pos_start_learning, pos_end_learning, parms, flagReinit,weights_init);
else
    weights = compute_weight_matrix(m_dot_values, sensor_values, pos_start_learning, pos_end_learning, parms,flagReinit,weights_init);
end

end

