function r = oja_diff_learning_rule(m_i, s_j_dot, w_i_j)
    %same as oja_diff_learning_rule of robotis_lib
    %r = -1*( m_i * s_j_dot + m_i * m_i * w_i_j);
    r = m_i * s_j_dot - m_i * m_i * w_i_j;
    
end