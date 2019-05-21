function [m_dot_learning,m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,flagFilter)


%filtering if needed 
if flagFilter == 1
    if isfield(parms,'use_filter') && parms.use_filter==1
        motor_pos_filtered = myfilter(lpdata.motor_position,parms.add_filter_size+1);
    else
        motor_pos_filtered = myfilter(lpdata.motor_position);
    end
    data_for_msdotpos = motor_pos_filtered;
else
    data_for_msdotpos = lpdata.motor_position;
end

%m s dot pos is created by differentiation
m_s_dot_pos = zeros(data.count_frames,parms.n_m);
for m=1:parms.n_m
    for i=2:data.count_frames
        m_s_dot_pos(i,m)=(data_for_msdotpos(m,i)-data_for_msdotpos(m,i-1))/(lpdata.motor_timestamp(m,i)-lpdata.motor_timestamp(m,i-1));
    end
end

%m dot learning is filled by tracking ipart to know when the motor action
%changes
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