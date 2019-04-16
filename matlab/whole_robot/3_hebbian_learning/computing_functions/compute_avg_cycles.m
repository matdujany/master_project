function [lpdata,data,idx_start,idx_end] = compute_avg_cycles(lpdata,data,parms)
%COMPUTE_AVG_CYCLES Summary of this function goes here
%   Detailed explanation goes here
n_frames_part0 = floor(parms.duration_part0/parms.time_interval_twitch);
n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
n_frames_part2 = floor(parms.duration_part2/parms.time_interval_twitch);

nb_theo_frames_per_twitch = (n_frames_part0+n_frames_part1+n_frames_part2)*(parms.n_m*parms.n_dir);

if size(lpdata.motor_position,2) ~= parms.n_twitches*nb_theo_frames_per_twitch
    disp('Pb with number of frames');
end

period = nb_theo_frames_per_twitch;

%unfiltered motor data averages;
flagFilter = 0;
[m_dot_learning,m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,flagFilter);
for motor = 1:parms.n_m
    [lpdata.motor_position_avg(motor,:), lpdata.motor_position_std(motor,:)] = compute_avg_cycle(lpdata.motor_position(motor,:),period);  
    [lpdata.motor_load_avg(motor,:), lpdata.motor_load_std(motor,:)] = compute_avg_cycle(lpdata.motor_load(motor,:),period);    
    [lpdata.m_s_dot_pos_avg(motor,:), lpdata.m_s_dot_pos_std(motor,:)] = compute_avg_cycle(m_s_dot_pos(:,motor),period);       
end
lpdata.m_s_dot_pos = m_s_dot_pos;
lpdata.m_dot_learning = m_dot_learning;
[lpdata.m_dot_learning_avg, lpdata.m_dot_learning_std] = compute_avg_cycle(m_dot_learning,period);    


%filtered motor data averages;
flagFilter = 1;
[m_dot_learning_filtered,m_s_dot_pos_filtered]  = compute_mdot_learning(data,lpdata,parms,flagFilter);

lpdata = compute_filtered_signal_lpdata(lpdata,parms);
for motor = 1:parms.n_m
    [lpdata.motor_positionfiltered_avg(motor,:), lpdata.motor_positionfiltered_std(motor,:)] = compute_avg_cycle(lpdata.motor_positionfiltered(motor,:),period);  
    [lpdata.motor_loadfiltered_avg(motor,:), lpdata.motor_loadfiltered_std(motor,:)] = compute_avg_cycle(lpdata.motor_loadfiltered(motor,:),period);    
    [lpdata.m_s_dot_posfiltered_avg(motor,:), lpdata.m_s_dot_posfiltered_std(motor,:)] = compute_avg_cycle(m_s_dot_pos_filtered(:,motor),period);    
end
lpdata.m_dot_learningfiltered = m_dot_learning_filtered;
[lpdata.m_dot_learningfiltered_avg, lpdata.m_dot_learningfiltered_std] = compute_avg_cycle(m_dot_learning_filtered,period);    

%unfiltered sensory data average signals.
for index_lc = 1:parms.nr_arduino
    for index_channel = 1:3
        [data.float_value_time_avg{1,index_lc}(:,index_channel), data.float_value_time_std{1,index_lc}(:,index_channel)]= compute_avg_cycle(data.float_value_time{1,index_lc}(:,index_channel),period);
        signal_dot = data.float_value_dot_time{1,index_lc}(:,index_channel);
        [data.float_value_dot_time_avg{1,index_lc}(:,index_channel), data.float_value_dot_time_std{1,index_lc}(:,index_channel)] = compute_avg_cycle(signal_dot,period);    
    end
end

%filtered sensory data average signals
data = compute_filtered_signal_data(data,parms);

for index_lc = 1:parms.nr_arduino
    for index_channel = 1:3
        [data.s_lc_filtered_avg(:,index_channel+3*(index_lc-1)), data.s_lc_filtered_std(:,index_channel+3*(index_lc-1))]=...
            compute_avg_cycle(data.s_lc_filtered(:,index_channel+3*(index_lc-1)),period);
        [data.s_dot_lc_filtered_avg(:,index_channel+3*(index_lc-1)), data.s_dot_lc_filtered_std(:,index_channel+3*(index_lc-1))]=...
            compute_avg_cycle(data.s_dot_lc_filtered(:,index_channel+3*(index_lc-1)),period);
    end
end
for index_ch_IMU = 1: parms.n_useful_ch_IMU
    [data.s_IMU_filtered_avg(:,index_ch_IMU), data.s_IMU_filtered_std(:,index_ch_IMU)]=...
        compute_avg_cycle(data.s_IMU_filtered(:,index_ch_IMU),period);
end

[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
idx_start = pos_start_learning(1:parms.n_m*parms.n_dir);  
idx_end = pos_end_learning(1:parms.n_m*parms.n_dir);  

lpdata = orderfields(lpdata);
data = orderfields(data);


end


function [average_period, std_period] = compute_avg_cycle(signal,period)
nb_samples = length(signal);
if mod(nb_samples,period) ~= 0
    disp('The number of samples is not an integer multiple of the period, returning 0');
    average_period = 0;
    return;
end
signal_temp = reshape(signal,period,nb_samples/period);
average_period = mean(signal_temp,2);
std_period = std(signal_temp,[],2);
end