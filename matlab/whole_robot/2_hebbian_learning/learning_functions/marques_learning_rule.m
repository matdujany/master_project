function Q = marques_learning_rule(m,s_dot)

m = m(1:end-1);

eta = 1 / (max(s_dot) * sum(m));

Q = - eta * sum(m' * s_dot);

end