close all;
clc; clear;

n_legs = 6;
total_load = 19;
load_per_leg = total_load/n_legs;

inv_map = [
[-0.490, 0.100, 0.227, -0.308, 0.074, 0.287] ,
[0.428, -1.000, 0.550, -0.051, -0.002, 0.088] ,
[0.134, 0.391, -0.697, 0.280, 0.264, -0.437] ,
[-0.449, 0.061, 0.343, -0.719, 0.579, 0.089] ,
[0.036, 0.007, -0.097, 0.456, -0.786, 0.329] ,
[0.214, 0.039, -0.294, 0.156, 0.209, -0.377] ];

prob = optimproblem('ObjectiveSense','minimize');
margin = 0.3;
x = optimvar('x',n_legs,1,'Type','continuous','LowerBound',load_per_leg-margin,'UpperBound',load_per_leg+margin);
prob.Objective = sum((inv_map*x).*(inv_map*x));
prob.Constraints.total_load_constraint = sum(x) == total_load;

sol = solve(prob);