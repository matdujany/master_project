function weights = compute_weights_wrapper(data,lpdata,parms,flagFilter,flagPlot,flagDetailed,flagReinit,weights_init)
%compute_weights_wrapper Summary of this function goes here
%   Detailed explanation goes here

[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,flagPlot);

%% Creating s and s_dot matrix
if flagFilter == 1 || parms.use_filter == 1
    disp('using filtered data');
    data = compute_filtered_signal_data(data,parms);
    s_dot_lc = data.s_dot_lc_filtered;
    s_IMU = data.s_IMU_filtered;
    [m_dot_values,~]  = compute_mdot_learning(data,lpdata,parms,1);
else
    s_dot_lc = zeros(data.count_frames,parms.n_lc * parms.n_ch_lc);
    %-1 because the diff makes us lose 1 frame.
    for i=1:parms.n_lc
        s_dot_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_dot_time{i};
    end
    
    %we never diff the IMU
    if parms.IMU_offsets
        s_IMU = data.IMU_corrected;
    else
        s_IMU = data.float_value_time{parms.n_lc+1};
    end
    
    %% create m_dot_matrix
    [m_dot_values,~]  = compute_mdot_learning(data,lpdata,parms,0);
end
%%
sensor_values = [s_dot_lc s_IMU(:,1:parms.n_useful_ch_IMU)];

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

