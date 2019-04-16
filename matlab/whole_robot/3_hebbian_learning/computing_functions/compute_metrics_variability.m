function [lc_dot_var,m_dot_var,m_dot_learning_var] = compute_metrics_variability(lpdata,data,parms)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
[lpdata,data,idx_start,idx_end] = compute_avg_cycles(lpdata,data,parms);

idx_learning = [];
for i=1:length(idx_start)
    idx_learning = [idx_learning idx_start(i):idx_end(i)];
end

lc_dot_var.raw_mean_std = zeros(parms.n_lc,3);
lc_dot_var.raw_max_std = zeros(parms.n_lc,3);
lc_dot_var.filtered_mean_std = zeros(parms.n_lc,3);
lc_dot_var.filtered_max_std = zeros(parms.n_lc,3);
for i=1:parms.n_lc
    [lc_dot_var.raw_mean_std(i,:), lc_dot_var.raw_max_std(i,:)] = compute_metrics(data.float_value_dot_time_std{1,i}(idx_learning,:));
    [lc_dot_var.filtered_mean_std(i,:), lc_dot_var.filtered_max_std(i,:)] = compute_metrics(data.s_dot_lc_filtered_std(idx_learning,3*(i-1)+1:3*i));
end

m_dot_var.raw_mean_std = zeros(parms.n_m,1);
m_dot_var.raw_max_std = zeros(parms.n_m,1);
m_dot_var.filtered_mean_std = zeros(parms.n_m,1);
m_dot_var.filtered_max_std = zeros(parms.n_m,1);
for i=1:parms.n_m
    [m_dot_var.raw_mean_std(i,:), m_dot_var.raw_max_std(i,:)] = compute_metrics((lpdata.m_s_dot_pos_std(i,idx_learning))');
    [m_dot_var.filtered_mean_std(i,:), m_dot_var.filtered_max_std(i,:)] = compute_metrics((lpdata.m_s_dot_posfiltered_std(i,idx_learning))');
end

[m_dot_learning_var.raw_mean_std, m_dot_learning_var.raw_max_std] = compute_metrics(lpdata.m_dot_learning_std);
[m_dot_learning_var.filtered_mean_std, m_dot_learning_var.filtered_max_std] = compute_metrics(lpdata.m_dot_learningfiltered_std);

end

function [mean_std, max_std] = compute_metrics(input_signal_std)
%input_signal_std is nbSamplesxnbChannels
nbChannels = size(input_signal_std,2);
max_std = zeros(1,nbChannels);
mean_std = zeros(1,nbChannels);
for channel = 1:nbChannels
    max_std(1,channel) = max(input_signal_std(:,channel));
    mean_std(1,channel) = mean(input_signal_std(:,channel));  
end
end