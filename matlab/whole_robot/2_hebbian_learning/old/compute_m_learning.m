function [m_learning]  = compute_m_learning(data,lpdata,parms)

m_learning = zeros(data.count_frames,1);
idx_new_cycle = find(diff(lpdata.i_part)==-2);
start_idx = 1;
count = 0;
for i=1:length(idx_new_cycle)
    idx_motor=mod(floor(count/2),parms.n_m)+1;
    m_learning(start_idx:idx_new_cycle(i))=lpdata.motor_position(idx_motor,start_idx:idx_new_cycle(i));
    start_idx = idx_new_cycle(i)+1;
    count = count+1;
end

end