%gait plot

clear; close all; clc;
addpath('../2_load_data_code');
addpath(genpath('../4_locomotion'));

%%
n_limb = 6;

[inverse_map,~] = get_inverse_map("X",110);

i_limb_ref_phase = 1;
fun = @(psi)sys_eqn(psi,inverse_map,i_limb_ref_phase);

psi0 = 2*pi*rand(n_limb,1);
psi0(i_limb_ref_phase,1) = 0; %%super important
psi0
[psi_sol,psi_dot_sol,exitflag,output] = fsolve(fun,psi0);
psi_sol
% psi_fail =[
%     1.5075
%          0
%     0.1802
%     3.0781
%     1.0551
%     6.1492];

psi_trot = [0;pi;0;pi];
psi_bipod = [0;2*pi/3;-2*pi/3;0;-4*pi/3;-2*pi/3];
