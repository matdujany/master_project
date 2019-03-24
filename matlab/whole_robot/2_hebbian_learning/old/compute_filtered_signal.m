function [data,lpdata] = compute_filtered_signal(data,lpdata,parms,flag_m_dot_pos_only)

scale_m_dot = 1;

if nargin == 3
    flag_m_dot_pos_only = false;
end

lpdata.motor_pos_filtered = myfilter(lpdata.motor_position);
lpdata.m_dot_pos_filtered = zeros(parms.n_m,data.count_frames);
for m=1:parms.n_m
    for i=2:data.count_frames
        lpdata.m_dot_pos_filtered(m,i)=scale_m_dot*(lpdata.motor_pos_filtered(m,i)-lpdata.motor_pos_filtered(m,i-1))/(lpdata.motor_timestamp(m,i)-lpdata.motor_timestamp(m,i-1));
    end
end

if flag_m_dot_pos_only
    return;
end

lpdata.motor_load_filtered = myfilter(lpdata.motor_load);


s_IMU = data.float_value_time{parms.n_lc+1}; %we dont diff the IMUS.
s_lc = zeros(data.count_frames,parms.n_lc * parms.n_ch_lc);
for i=1:parms.n_lc
    s_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_time{i};
end

data.s_IMU_filtered = myfilter(s_IMU);
data.s_lc_filtered = myfilter(s_lc);

data.s_dot_lc_filtered = zeros(data.count_frames-1,parms.n_lc * parms.n_ch_lc);
for i=1:parms.n_lc
    for j=1:parms.n_ch_lc
        data.s_dot_lc_filtered(:,j+3*(i-1))=10^3*diff(data.s_lc_filtered(:,j+3*(i-1)))./diff(data.time(:,i));
    end
end
%adding a line of zeros so that the timelines match
data.s_dot_lc_filtered = [zeros(1,parms.n_lc * parms.n_ch_lc);data.s_dot_lc_filtered];


end