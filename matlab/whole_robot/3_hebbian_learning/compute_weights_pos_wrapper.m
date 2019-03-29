function weights_pos = compute_weights_pos_wrapper(data,lpdata,parms,flagFilter,flagPlot,weights_pos_init)
%compute_weights_wrapper Summary of this function goes here
%   Detailed explanation goes here
%%
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,flagPlot);
%% Creating s and s_dot matrix
[m_dot_learning, m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,flagFilter);

%%
if nargin == 5
    weights_pos_init = zeros(parms.n_m,2*parms.n_m);
end

weights_pos = compute_weight_matrix(m_dot_learning, m_s_dot_pos, pos_start_learning, pos_end_learning, parms,weights_pos_init);

if flagPlot
    h=hinton(weights_pos{parms.n_twitches});
end

end

