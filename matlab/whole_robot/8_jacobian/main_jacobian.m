close all; clc; clear;
recordID = 251;

[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);
n_limb = size(data.time,2)-1;

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
time = pos_phi_data.phi_update_timestamp;
time = (time-time(1))/10^3;
%%
figure;
hold on;
for i=1:n_limb
    plot(time,phi(:,i));
end

%%
limb =  [9    10;   7    1;    4     5;     2     3;     6     8;     11     12];

figure;
for i=1:n_limb
    subplot(2,n_limb/2,i);
    motor_pos_hip = pos_phi_data.motor_position(limb(i,1),:);
    motor_pos_knee = pos_phi_data.motor_position(limb(i,2),:);
    hold on;
    plot(time,motor_pos_hip);
    plot(time,motor_pos_knee);
    legend('Hip','Knee');
end


%%
i_limb = 1;
t_start = 15*(i_limb-1);
t_stop = 15*i_limb;
[~, i_start] = min(abs(time-t_start));
[~, i_stop] = min(abs(time-t_stop));

n_limb_plot = 6;

figure;
hold on;
for i=1:n_limb_plot
    scatter(phi(i_start:i_stop,i_limb),GRF(i_start:i_stop,i));
end


%% padding to make it really periodic

phi_extracted = phi(i_start:i_stop,i_limb);
N_extracted = GRF(i_start:i_stop,:);

phi_grid = uniquetol(phi_extracted,10^-2);
N_grid = zeros(length(phi_grid),n_limb);

for i=1:length(phi_grid)
    idx_tmp = phi_grid(i)==phi_extracted;
    N_grid(i,:) = mean(N_extracted(idx_tmp,:),1);
end

margin_pad = 1; %in radians

[~,idx1] = min(abs(phi_grid-margin_pad));
phi_grid_padded = [phi_grid; 2*pi + phi_grid(1:idx1)];
N_padded = [N_grid; N_grid(1:idx1,:)];

[~,idx2] = min(abs(phi_grid_padded-(2*pi-margin_pad)));
phi_grid_padded = [ - 2*pi + phi_grid_padded(idx2:end); phi_grid_padded];
N_padded = [N_padded(idx2:end,:); N_padded];


figure;
hold on;
for i=1:n_limb_plot
    scatter(phi_grid_padded,N_padded(:,i));
end

phi_query = linspace(0,2*pi,200)';
N_guessed_from_grid = zeros(length(phi_query),n_limb);
for i=1:n_limb
    profile_spline(i) = spline(phi_grid_padded,N_padded(:,i));
    N_guessed_from_grid(:,i) = ppval(profile_spline(i),phi_query);
end

figure;
hold on;
for i=1:n_limb_plot
    plot(phi_query,N_guessed_from_grid(:,i));
end
ylabel('N');
xlabel(['\phi_ ' num2str(i_limb)]);
title('Spline approximation');


for i=1:n_limb
    N_smoothed(:,i) = smooth(N_guessed_from_grid(:,i),10,'rloess');
end

figure;
hold on;
for i=1:n_limb_plot
    plot(phi_query,N_smoothed(:,i));
end
ylabel('N');
xlabel(['\phi_ ' num2str(i_limb)]);
title('After smoothing');


delta_phi = 2*pi*parms_locomotion.frequency * (25*10^-3); % 25 ms, delay update tegotae;

dN_dphi_g = diff(N_smoothed)/delta_phi;
dN_dphi_grid = (phi_query(1:end-1) + phi_query(2:end))/2;

%%
% figure;
% hold on;
% for i=1:n_limb
%     plot(dN_dphi_grid,dN_dphi_g(:,i));
% end
% 
% 
