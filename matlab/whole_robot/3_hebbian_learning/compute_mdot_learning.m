function [m_dot_learning,m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,flagFilter)

%to do : maybe this should be scaled to seconds.
scale_m_dot = 1;
% 
m_s_dot_pos = zeros(data.count_frames,parms.n_m);
if flagFilter == 1
    motor_pos_filtered = myfilter(lpdata.motor_position);
    for m=1:parms.n_m
        for i=2:data.count_frames
            m_s_dot_pos(i,m)=scale_m_dot*(motor_pos_filtered(m,i)-motor_pos_filtered(m,i-1))/(lpdata.motor_timestamp(m,i)-lpdata.motor_timestamp(m,i-1));
        end
    end
else
    m_s_dot_pos = zeros(data.count_frames,parms.n_m);
    for m=1:parms.n_m
        for i=2:data.count_frames
            m_s_dot_pos(i,m)=scale_m_dot*(lpdata.motor_position(m,i)-lpdata.motor_position(m,i-1))/(lpdata.motor_timestamp(m,i)-lpdata.motor_timestamp(m,i-1));
        end
    end
end
% 
% for i=1:parms.n_m
%     m_s_dot_pos(:,i)=[0 diff(lpdata.motor_position(i,:))];
% end

%% create m_dot_matrix

m_dot_learning = zeros(data.count_frames,1);
idx_new_cycle = find(diff(lpdata.i_part)==-2);
start_idx = 1;
count = 0;
for i=1:length(idx_new_cycle)
    idx_motor=mod(floor(count/2),parms.n_m)+1;
    m_dot_learning(start_idx:idx_new_cycle(i))=m_s_dot_pos(start_idx:idx_new_cycle(i),idx_motor);
    start_idx = idx_new_cycle(i)+1;
    count = count+1;
end

m_dot_learning(start_idx:data.count_frames)=m_s_dot_pos(start_idx:data.count_frames,parms.n_m);
end