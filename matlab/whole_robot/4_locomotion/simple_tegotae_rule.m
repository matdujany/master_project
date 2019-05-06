function phi_dot = simple_tegotae_rule(phase,ground_reaction_force,parms_locomotion)
  phi_dot = 2 * pi * parms_locomotion.frequency - parms_locomotion.sigma_s * ground_reaction_force * cos(phase);
end

