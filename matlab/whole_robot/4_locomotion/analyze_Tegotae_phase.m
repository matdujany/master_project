clear; close all; clc;
addpath('../2_load_data_code');



%% use gait plot to pick t start and t stop
%%%%% quad
recordID = 108; 
n_limb = 4;
t_start = 15;
t_stop = 25;

%%%% hexa
recordID = 227; %139: n dot %132 hardcoded bipod
n_limb = 6;
t_start = 92;
t_stop = 112;

recordID = 230; %139: n dot %132 hardcoded bipod
n_limb = 6;
t_start = 80;
t_stop = 100;


%%%% octo
% recordID = 50;
% disp('Warning! Pb with phase locking of limb 1');
% n_limb = 8;
% t_start = 60;
% t_stop = 76;

compute_tegotae_advanced = true;

%%
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
parms_locomotion.frequency = 0.5;

n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);
phi = pos_phi_data.limb_phi;

if abs(n_samples_phi-n_samples_GRF)>1
    disp('Warning ! Number of samples dont agree');
    if n_samples_phi == n_samples_GRF+1
        phi = pos_phi_data.limb_phi(:,2:end);
    end
end
    
phi = phi';

% GRF = zeros(n_samples,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end

%filtered version:
size_mv_average = 10;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
GRF_filtered = zeros(size(GRF));
for i=1:n_limb
%     GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i)); %causal
    GRF_filtered(:,i) = filtfilt(filter_coeffs,1,GRF(:,i)); %non-causal
end

%%
order = 2;
framelen = 15;
% GRF_filtered = sgolayfilt(GRF,order,framelen);

threshold_unloading = 0.2; %Fukuhuara, figure 6, stance if more than 20% of maximal value
[value_unloading,max_value_GRF_limb] = determine_value_unloading(GRF,threshold_unloading);

%% computing N_dots
for i=1:n_limb
    N_dot(:,i) = 10^3*diff(GRF(:,i))./diff(data.time(:,i));
    N_dot_filtered(:,i) = 10^3*diff(GRF_filtered(:,i))./diff(data.time(:,i));
end

%% computing phase updates
phi_dots = zeros(size(phi)-[1 0]);
diff_phi = diff(phi);
diff_phi(diff_phi<-6) = diff_phi(diff_phi<-6)+2*pi;
for i=1:n_limb
    phi_dots(:,i) = 10^3*diff_phi(:,i)./diff(pos_phi_data.phi_update_timestamp)' - 2*pi*parms_locomotion.frequency;
%     phase_updates(:,i) = diff_phi(:,i)./0.021 - 2*pi*parms_locomotion.frequency;

end

%% plotting parameters
i_limb_plot = 2;
time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
[~,index_start] = min(abs(time-t_start));
[~,index_stop] = min(abs(time-t_stop));
dot_size = 15;

%% subplots 
i_limb_plot = 2;

figure;
% GRFs
plot_grf_phase(i_limb_plot,phi,GRF,index_start,index_stop,dot_size,t_start,t_stop);

for i=1:n_limb
    profile_spline(i) = get_spline_profile(GRF(index_start:index_stop,i),phi(index_start:index_stop,i)); 
end

figure;
phi_query = linspace(0,2*pi,100)';
hold on
for i=1:n_limb
    plot(phi_query,ppval(profile_spline(i),phi_query));
end
plot(phi_query,func_N_ref(phi_query),'k--');

function profile_spline = get_spline_profile(GRF_source,phi_source)
%GRF is n_points x 1

%% padding to make signal periodic
margin_pad = 0.5; %in radians
[~,idx1] = min(abs(phi_source-margin_pad));
phi_source = [phi_source; 2*pi + phi_source(1:idx1)];
GRF_source = [GRF_source; GRF_source(1:idx1)];
[~,idx2] = min(abs(phi_source-(2*pi-margin_pad)));
phi_source = [ - 2*pi + phi_source(idx2:end); phi_source];
GRF_source = [GRF_source(idx2:end); GRF_source];
[phi_source, index] = unique(phi_source); 
GRF_source = GRF_source(index);


%% we reduce the number of points by subsampling, using an average
grid_x = linspace(0-margin_pad,2*pi+margin_pad,100);
phi_grid = zeros(length(grid_x)-1,1);
GRF_grid = zeros(length(grid_x)-1,1);
for i=1:length(grid_x)-1
    idx = find(grid_x(i)<phi_source & phi_source<grid_x(i+1));
    phi_grid(i,1) = (grid_x(i) + grid_x(i+1))/2;
    GRF_grid(i,1) = mean(GRF_source(idx));
end

profile_spline = spline(phi_grid,GRF_grid);

end