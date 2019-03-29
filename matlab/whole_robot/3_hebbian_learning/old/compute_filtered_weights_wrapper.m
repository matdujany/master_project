function weights = compute_filtered_weights_wrapper(data,lpdata,parms,flagPlot,weights_init)
%compute_weights_wrapper Summary of this function goes here
%   Detailed explanation goes here
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,flagPlot);

%% Creating s and s_dot matrix
% s_IMU = data.float_value_time{parms.n_lc+1}; %we dont diff the IMUS.
% s_lc = zeros(data.count_frames,parms.n_lc * parms.n_ch_lc);
% for i=1:parms.n_lc
%     s_lc(:,1+parms.n_ch_lc*(i-1):parms.n_ch_lc*i)=data.float_value_time{i};
% end
% 
% s_IMU_filtered = myfilter(s_IMU);
% s_lc_filtered = myfilter(s_lc);
% 
% s_dot_lc_filtered = zeros(data.count_frames-1,parms.n_lc * parms.n_ch_lc);
% for i=1:parms.n_lc
%     for j=1:parms.n_ch_lc
%         s_dot_lc_filtered(:,j+3*(i-1))=10^3*diff(s_lc_filtered(:,j+3*(i-1)))./diff(data.time(:,i));
%     end
% end
% %adding a line of zeros so that the timelines match
% s_dot_lc_filtered = [zeros(1,parms.n_lc * parms.n_ch_lc);s_dot_lc_filtered];
% 
% %% create m_dot_matrix
% flagFilter = 1;
% [m_dot_postfiltering,~]  = compute_mdot_learning(data,lpdata,parms,flagFilter);

%%
[data,lpdata] = compute_filtered_signal(data,lpdata,parms);
sensor_values_filtered = [data.s_dot_lc_filtered data.s_IMU_filtered(:,1:parms.n_useful_ch_IMU)];

%% create m_dot_matrix
flagFilter = 1;
[m_dot_learning_postfiltering,~]  = compute_mdot_learning(data,lpdata,parms,flagFilter);

if nargin == 4
    weights_init = zeros(parms.n_lc*parms.n_ch_lc+parms.n_useful_ch_IMU,2*parms.n_m);
end

weights = compute_weight_matrix(m_dot_learning_postfiltering, sensor_values_filtered, pos_start_learning, pos_end_learning, parms,weights_init);
end

