function weights_pos = compute_weights_pos_wrapper(data,lpdata,parms,flagFilter,flagPlot,flagDetailed,weights_pos_init)
%compute_weights_wrapper Summary of this function goes here
%   Detailed explanation goes here
%%
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,flagPlot);
%% Creating s and s_dot matrix
flagFiltercombined = (flagFilter == 1 || parms.use_filter == 1);
[m_dot_learning, m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,flagFiltercombined);

%%
if nargin == 5
    flagDetailed = 0;
    weights_pos_init = zeros(parms.n_m,2*parms.n_m);
end

if nargin == 6
    weights_pos_init = zeros(parms.n_m,2*parms.n_m);
end

if flagDetailed == 1
    weights_pos = compute_weight_detailled_evolution(m_dot_learning, m_s_dot_pos, pos_start_learning, pos_end_learning, parms, 0,weights_pos_init);
else
    weights_pos = compute_weight_matrix(m_dot_learning, m_s_dot_pos, pos_start_learning, pos_end_learning, parms,weights_pos_init);
end

if flagPlot
    h=hinton(weights_pos{parms.n_twitches});
end

end

