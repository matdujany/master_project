function weights_pos = compute_weights_pos_wrapper(data,lpdata,parms,flagPlot)
%compute_weights_wrapper Summary of this function goes here
%   Detailed explanation goes here
%%
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
%% Creating s and s_dot matrix
s_dot_pos = zeros(data.count_frames-1,parms.n_m);

for i=1:parms.n_m
    s_dot_pos(:,i)=diff(lpdata.motor_position(i,:));
end

%% create m_dot_matrix

m_dot_values = zeros(data.count_frames-1,1);
for i=1:data.count_frames-1
    m_dot_values(i)=(lpdata.last_motor_pos(i+1)-lpdata.last_motor_pos(i))/(lpdata.last_motor_timestamp(i+1)-lpdata.last_motor_timestamp(i));
end

%%
weights_pos = compute_weight_matrix(m_dot_values, s_dot_pos, pos_start_learning, pos_end_learning, parms);

if flagPlot
    h=hinton(weights_pos{parms.n_twitches});
end

end

