function weights = compute_weights_wrapper(data,lpdata,parms)
%compute_weights_wrapper Summary of this function goes here
%   Detailed explanation goes here
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);

%% Creating s and s_dot matrix
s_dot_lc = zeros(data.count_frames-1,parms.n_lc * parms.n_ch_lc);
%-1 because the diff makes us lose 1 frame.
for i=1:parms.n_lc
    s_dot_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_dot_time{i};
end
s_dot_lc = [s_dot_lc;zeros(1,parms.n_lc * parms.n_ch_lc)]; %just adding a line of zeros

s_IMU = data.float_value_time{parms.n_lc+1}; %we dont diff the IMUS.
s_lc = zeros(data.count_frames,parms.n_lc * parms.n_ch_lc);
for i=1:parms.n_lc
    s_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_time{i};
end

%% create m_dot_matrix
m_dot_values = zeros(data.count_frames-1,1);
for i=1:data.count_frames-1
    m_dot_values(i)=(lpdata.last_motor_pos(i+1)-lpdata.last_motor_pos(i))/(lpdata.last_motor_timestamp(i+1)-lpdata.last_motor_timestamp(i));
end

%%
sensor_values = [s_dot_lc s_IMU(:,1:parms.n_useful_ch_IMU)];
weights = compute_weight_matrix(m_dot_values, sensor_values, pos_start_learning, pos_end_learning, parms);
end

