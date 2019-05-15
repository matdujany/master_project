function phi_dot = simple_tegotae_rule(phase,ground_reaction_force,frequency,sigma_s)
  phi_dot = 2 * pi * frequency - sigma_s * ground_reaction_force * cos(phase);
end

