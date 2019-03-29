function weights_pos = compute_filtered_weights_pos_wrapper(data,lpdata,parms,flagPlot,weights_pos_init)
%compute_weights_wrapper Summary of this function goes here
%   Detailed explanation goes here
%%
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,flagPlot);
%% Creating s and s_dot matrix
flagFilter = 1;
[m_dot_learning_filtered,m_s_dot_pos_filtered]  = compute_mdot_learning(data,lpdata,parms,flagFilter);


%%
if nargin == 4
    weights_pos_init = zeros(parms.n_m,2*parms.n_m);
end

% figure;
% legend_list = cell(parms.n_m,1);
% hold on;
% for i=1:parms.n_m
%     plot(m_s_dot_pos_filtered(:,i))
%     legend_list{i}=['M' num2str(i)];
% end
% legend(legend_list)

% figure;
% legend_list = cell(parms.n_m,1);
% hold on;
% for i=1:parms.n_m
%     plot(lpdata.motor_position(i,:))
%     legend_list{i}=['M' num2str(i)];
% end
% legend(legend_list)


weights_pos = compute_weight_matrix(m_dot_learning_filtered, m_s_dot_pos_filtered, pos_start_learning, pos_end_learning, parms,weights_pos_init);

if flagPlot
    h=hinton(weights_pos{parms.n_twitches});
end

end

