close all;
clc; clear;

n_legs = 6;
total_load = 19;

inv_map = [
[-0.490, 0.100, 0.227, -0.308, 0.074, 0.287] ,
[0.428, -1.000, 0.550, -0.051, -0.002, 0.088] ,
[0.134, 0.391, -0.697, 0.280, 0.264, -0.437] ,
[-0.449, 0.061, 0.343, -0.719, 0.579, 0.089] ,
[0.036, 0.007, -0.097, 0.456, -0.786, 0.329] ,
[0.214, 0.039, -0.294, 0.156, 0.209, -0.377] ];

fun = @(x) sum( abs( (inv_map*x(1:n_legs))); %we want

thresh = 0.2;

GRF_0 = total_load/n_legs*ones(n_legs,1);
phi_0 = zeros(n_legs,1);

% x = fmincon(fun,GRF_0,A,b)
A1=[-eye(n_legs) zeros(n_legs)];
b1=zeros(n_legs,1);
% A2 = ones(1,n_legs);
% b2 = (1+thresh)*total_load;
% A3 = -ones(1,n_legs);
% b3 = -(1-thresh)*total_load;
% 
% A=[A1; A2; A3];
% b= [b1; b2; b3];

Aeq = [ones(1,n_legs) zeros(1,n_legs)];

x_0 = [GRF_0; phi_0];
[x_stable,fval,exitflag,output]  = fmincon(fun,x_0,A1,b1,Aeq,total_load);
GRF = x_stable(1:n_legs);
phi = x_stable(n_legs+1:2*n_legs);
