function weights_speed = compute_weights_speed(data,lpdata,parms)

[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);

integrated_speed = compute_integrated_speed(data,lpdata,parms);


[m_dot_values,m_s_dot_pos]  = compute_mdot_learning(data,lpdata,parms,1);

if isfield(parms,'twitch_limb') &&  parms.twitch_limb== 1
    weights_speed = compute_weight_matrix_twitch_limb(m_s_dot_pos, integrated_speed, pos_start_learning, pos_end_learning, parms, 0);
else
    weights_speed = compute_weight_matrix(m_dot_values, integrated_speed, pos_start_learning, pos_end_learning, parms, 0);
end

end