function weights_speed = compute_weights_speed(data,lpdata,parms)

[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);

integrated_speed = zeros(size(data.IMU_corrected,1),3);

data_IMU_filtered = myfilter(data.IMU_corrected);
for i=1:length(pos_start_learning)
    for k=pos_start_learning(i):pos_end_learning(i)
        integrated_speed(k,:) = integrated_speed(k-1,:)+data_IMU_filtered(k,1:3)*(9.81/256)*parms.time_interval_twitch*10^-3;
    end
end


[m_dot_values,~]  = compute_mdot_learning(data,lpdata,parms,1);
weights_speed = compute_weight_matrix(m_dot_values, integrated_speed, pos_start_learning, pos_end_learning, parms, 0);

end