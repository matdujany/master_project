clear; close all; clc;
addpath('../2_load_data_code');



%% use gait plot to pick t start and t stop
%%%%% quad
% recordID = 108;
% n_limb = 4;
% t_start = 15;
% t_stop = 25;

%%%% hexa
recordID = 34; %139: n dot %132 hardcoded bipod
n_limb = 6;
t_start = 56;
t_stop = 70;

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


%% motor positions
pos = pos_phi_data.motor_position';
pos_filtered = filtfilt(filter_coeffs,1,pos);

pos_dots = zeros(size(pos)-[1 0]);
for i=1:n_limb
    pos_dots(:,i) = 10^3*diff(pos_filtered(:,i))./diff(pos_phi_data.phi_update_timestamp)';
end


%% time extraction
time = (data.time(:,1)-data.time(1,1))/10^3;
[~,index_start] = min(abs(time-t_start));
[~,index_stop] = min(abs(time-t_stop));

% N_extracted = GRF(index_start:index_stop,:);
N_extracted = GRF_filtered(index_start:index_stop,:);
N_dot_extracted = N_dot_filtered(index_start:index_stop,:);
pos_dot_extracted = pos_dots(index_start:index_stop,:);
phi_dot_extracted = phi_dots(index_start:index_stop,:);
phi_extracted = phi(index_start:index_stop,:);

%%
i_limb_ref_phi = 1;
figure;
subplot(1,3,1);
hold on;
for i=1:n_limb
    scatter(phi_extracted(:,i_limb_ref_phi),N_extracted(:,i));
end
ylabel('N');
xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
subplot(1,3,2);
hold on;
for i=1:n_limb
    scatter(phi_extracted(:,i_limb_ref_phi),N_dot_extracted(:,i));
end
xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
ylabel('dN/dt');

subplot(1,3,3);
hold on;
for i=1:n_limb
    scatter(phi_extracted(:,i_limb_ref_phi),phi_dot_extracted(:,i));
end
ylabel('phi dot');
xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);



%%
grid_phi = linspace(0,2*pi,50);
phidot_grid = zeros(length(grid_phi)-1,n_limb);
Ndot_grid = zeros(length(grid_phi)-1,n_limb);
N_grid = zeros(length(grid_phi)-1,n_limb);

% alphadot_grid = zeros(length(grid_phi)-1,n_limb);
phi_grid = (grid_phi(1,1:end-1) + grid_phi(1,2:end))/2;

dN_dphi = zeros(n_limb,length(grid_phi)-1);
for i=1:length(grid_phi)-1
    %     idx = find(grid_phi(i)<phi & phi<grid_phi(i+1));
    idx_tmp = grid_phi(i)<phi_extracted(:,i_limb_ref_phi) & phi_extracted(:,i_limb_ref_phi)<grid_phi(i+1);
    Ndot_grid(i,:) = mean(N_dot_extracted(idx_tmp,:),1);
    N_grid(i,:) = mean(N_extracted(idx_tmp,:),1);
    phidot_grid(i,:) = mean(phi_dot_extracted(idx_tmp,:),1);
end

figure;
hold on;
for i=1:n_limb
    plot(phi_grid,N_grid(:,i));
end
ylabel('N');
xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
title('N averaged over grid');

%%
phi_query = linspace(0,2*pi,100)';
N_guessed_from_grid = zeros(length(phi_query),n_limb);
for i=1:n_limb
    profile_spline(i) = spline(phi_grid,N_grid(:,i));
    N_guessed_from_grid(:,i) = ppval(profile_spline(i),phi_query);
end


figure;
hold on;
for i=1:n_limb
    plot(phi_query,N_guessed_from_grid(:,i));
end
ylabel('N');
xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
title('Spline approximation');


%%
phi_grid_diff = (phi_query(1:end-1) + phi_query(2:end))/2;
dN_dphi = diff(N_guessed_from_grid)./diff(phi_query);

figure;
hold on;
for i=1:n_limb
    plot(phi_grid_diff,dN_dphi(:,i));
end
xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
ylabel(['dN/d\phi_' num2str(i_limb_ref_phi)]);
title('Without smoothing');

%% padding to make it really periodic
margin_pad = 1; %in radians
[~,idx1] = min(abs(phi_grid_diff-margin_pad));
phi_grid_diff_padded = [phi_grid_diff; 2*pi + phi_grid_diff(1:idx1)];
dN_dphi_padded = [dN_dphi; dN_dphi(1:idx1,:)];
[~,idx2] = min(abs(phi_grid_diff-(2*pi-margin_pad)));
phi_grid_diff_padded = [ - 2*pi + phi_grid_diff(idx2:end); phi_grid_diff_padded];
dN_dphi_padded = [dN_dphi(idx2:end,:); dN_dphi_padded];



dN_dphi_smoothed = zeros(size(dN_dphi_padded));
for i=1:n_limb
    dN_dphi_smoothed(:,i) = smooth(dN_dphi_padded(:,i),30,'rloess');
end


figure;
hold on;
for i=1:n_limb
    plot(phi_grid_diff_padded,dN_dphi_smoothed(:,i));
end
xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
ylabel(['dN/d\phi_' num2str(i_limb_ref_phi)]);
xlim([0 2*pi]);
title('After smoothing');

switch n_limb
    case 4
        [inverse_map,~] = load_inverse_map("X",105);
    case 6
        [inverse_map,~] = load_inverse_map("X",110);
    otherwise
        disp('add maps for this number of limb');
end

figure;
hold on;
for i=1:n_limb
    plot(phi_grid_diff_padded,inverse_map(i_limb_ref_phi,i)*cos(phi_grid_diff_padded));
end
xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
ylabel(['inv-map(' num2str(i_limb_ref_phi) ',j)*cos(\phi_ ' num2str(i_limb_ref_phi) ')']);
xlim([0 2*pi]);
