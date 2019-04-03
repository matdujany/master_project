function data = compute_filtered_signal_data(data,parms)

if parms.IMU_offsets
    s_IMU = data.IMU_corrected;
else
    s_IMU = data.float_value_time{parms.n_lc+1};
end

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