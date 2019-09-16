%gait plot

clear; close all; clc;
addpath('../2_load_data_code');
addpath(genpath('../4_locomotion'));
addpath(genpath('../3_hebbian_learning'));
addpath(genpath('../6_online_learning'));

%%
n_limb = 6;
recordID = 110;

omega = 2*pi*0.5;
total_load = get_total_load(recordID,n_limb*2);
[inverse_map,sigma] = load_inverse_map("X",recordID);
inverse_map = load_inv_maps_online('test1');
% N_ref = 1.5*ones(n_limb,1);
% N_ref([1 3],1) = 6;
sigma = 0.2;
N_ref = zeros(n_limb,1);


profilparms.use_profilparms = 1;
profilparms.recordID = 34;
profilparms.i_limb = 3;

% inverse_map = [-1 0 0 0 0 1; 0 -1 0 0 1 0; 0 0 -1 1 0 0; 0 0 1 -1 0 0; 0 1 0 0 -1 0; 1 0 0 0 0 -1];
% [inverse_map,sigma] = load_inverse_map("X","115R");
% inverse_map = [-1 0.9 -1 0.95; 1 -1 1 -1; -1 1 -1 1; 1 -1 1 -1];
% sigma = 0.2;

% phi0 = 2*pi*rand(n_limb,1);
phi0 = zeros(n_limb,1);
% phi0 = [0;pi;0;pi;0;pi];

time_step = 25*10^-3; % in seconds
% time_step = 10^-3;
tmax = 120; %duration of simulation in seconds
tspan = 0:time_step:tmax;

odefun = @(t,phi)compute_phi_dot(t,phi,omega,inverse_map,sigma,total_load,N_ref,profilparms);
% [time,phi]=ode23tb(odefun,[0 tmax],phi0);
[time,phi]=ode23tb(odefun,tspan,phi0);

%%
GRF = estimate_GRF_from_phi(phi',total_load,n_limb,profilparms);
GRF = GRF';
% for i=1:length(time)
%     GRF(i,:) = estimate_GRF_from_phi(phi(i,:)',total_load,n_limb,profilparms);
% end
threshold_unloading = 0.2;
[f_GRF,ax_grf] = plot_GRF(GRF,time,threshold_unloading,recordID);

%%
phi = mod(phi,2*pi);
delta_phases = compute_delta_phases(phi');
[f_delta_phases,ax_delta_phases] = plot_delta_phases(time,delta_phases,recordID);

[f_gait,ax_gait] = plot_gait_diagram(GRF,time,threshold_unloading,recordID);
linkaxes([ax_grf;ax_gait; ax_delta_phases],'x');



%%
figure;
plot(sum(GRF,2));

figure;
subplot(1,2,1);
title('Load on the right');
plot(sum(GRF(:,1:n_limb/2),2));
ylim([0 15]);
subplot(1,2,2);
title('Load on the left');
plot(sum(GRF(:,n_limb/2+1:end),2));
ylim([0 15]);

%%
i_limb_plot = 2;
t_start = 30;
t_stop = 50;
[~,index_start] = min(abs(time-t_start));
[~,index_stop] = min(abs(time-t_stop));
dot_size = 15;

figure;
plot_grf_phase(i_limb_plot,phi,GRF,index_start,index_stop,dot_size,t_start,t_stop);

