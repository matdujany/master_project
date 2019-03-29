function lpdata = compute_filtered_signal_lpdata(lpdata,parms)

scale_m_dot = 1;

lpdata.motor_positionfiltered = myfilter(lpdata.motor_position);
lpdata.m_s_dot_pos = zeros(parms.n_m,length(lpdata.i_part));
lpdata.m_s_dot_posfiltered = zeros(parms.n_m,length(lpdata.i_part));
for m=1:parms.n_m
    for i=2:length(lpdata.i_part) 
        lpdata.m_s_dot_pos(m,i)=scale_m_dot*(lpdata.motor_position(m,i)-lpdata.motor_position(m,i-1))/(lpdata.motor_timestamp(m,i)-lpdata.motor_timestamp(m,i-1));
        lpdata.m_s_dot_posfiltered(m,i)=scale_m_dot*(lpdata.motor_positionfiltered(m,i)-lpdata.motor_positionfiltered(m,i-1))/(lpdata.motor_timestamp(m,i)-lpdata.motor_timestamp(m,i-1));
    end
end

lpdata.motor_loadfiltered = myfilter(lpdata.motor_load);

end