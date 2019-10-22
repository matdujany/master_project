close all; clc; clear;

addpath('../2_load_data_code');
addpath('../3_hebbian_learning');
addpath('../4_locomotion');

recordID = 261;
duration_per_limb = 80; %in seconds

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

%% position check
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values("X",n_limb,110);    
hip_motors = limb_ids(:,2);
knee_motors = limb_ids(:,1);

flag_CS = true;
if ismember(recordID,[257:259])
    flag_CS = false;
end



if flag_CS
    recordID_learning = 149;

else
    recordID_learning = 110;
end

neutral_pos = read_neutral_pos(recordID_learning, 12);
weights_robotis = read_weights_robotis(recordID_learning,parms);
    
figure;
for i=1:n_limb
    subplot(2,n_limb/2,i);
    motor_pos_hip = pos_phi_data.motor_position(limb_ids(i,2),:);
    motor_pos_knee = pos_phi_data.motor_position(limb_ids(i,1),:);
    t_start = duration_per_limb*(i-1);
    t_stop = duration_per_limb*i;
    phase = 2*pi*parms_locomotion.frequency*[0:25*10^-3:duration_per_limb];
    pos_theo_c2 = phase2pos_wrapper(phase,1,changeDir(i,2),parms_locomotion);
    pos_theo_c1 = phase2pos_wrapper(phase,0,changeDir(i,1),parms_locomotion);
    
    hold on;
    plot(time,motor_pos_hip,'r');
    plot(time,motor_pos_knee);    
    plot([t_start:25*10^-3:t_stop],pos_theo_c2,'r--');
    
    xlim([t_start t_stop] + 5*[-1 1]);
    xlabel('Time [s]');
    legend('Hip','Knee','Hip theo');
end


%%
i_limb = 1;
t_start = duration_per_limb*(i_limb-1);
t_stop = duration_per_limb*i_limb;
[~, i_start] = min(abs(time-t_start));
[~, i_stop] = min(abs(time-t_stop));

n_limb_plot = 6;

pi_label_list = {'0','\pi/2','\pi','3\pi/2','2\pi'};

figure;
hold on;
for i=1:n_limb_plot
    scatter(phi(i_start:i_stop,i_limb),GRF(i_start:i_stop,i));
    legend_list{i} = ['N ' num2str(i)];
end
xlabel(['Phase \phi_ ' num2str(i_limb) ' [rad]']);
xticks(pi/2*[0:4])
xticklabels(pi_label_list);
xlim([0 2*pi]);
ylabel('GRF [N]');
legend(legend_list);


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

[~,idx2] = min(abs(phi_grid-(2*pi-margin_pad)));
phi_grid_padded = [ - 2*pi + phi_grid(idx2:end); phi_grid_padded];
N_padded = [N_grid(idx2:end,:); N_padded];

%%
figure;
hold on;
for i=1:n_limb_plot
    scatter(phi_grid_padded,N_padded(:,i));
end
xlabel(['Phase \phi_ ' num2str(i_limb) ' [rad]']);
xticks(pi/2*[0:4])
xticklabels(pi_label_list);
xlim([0 2*pi]);
ylabel('GRF [N]');
legend(legend_list);

%%
phi_query = linspace(-margin_pad,2*pi+margin_pad,200)';
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
xlabel(['Phase \phi_ ' num2str(i_limb) ' [rad]']);
xticks(pi/2*[0:4])
xticklabels(pi_label_list);
xlim([0 2*pi]);
ylabel('GRF [N]');
title('Spline approximation');
legend(legend_list);


for i=1:n_limb
    N_smoothed(:,i) = smooth(N_guessed_from_grid(:,i),50,'rloess');
end

figure;
hold on;
for i=1:n_limb_plot
    plot(phi_query,N_smoothed(:,i));
end
ylabel('GRF [N]');
xlabel(['Phase \phi_ ' num2str(i_limb) ' [rad]']);
xticks(pi/2*[0:4])
xticklabels(pi_label_list);
xlim([0 2*pi]);
title('After smoothing');
legend(legend_list);


delta_phi = 2*pi*parms_locomotion.frequency * (25*10^-3); % 25 ms, delay update tegotae;

dN_dphi_g = diff(N_smoothed)./diff(phi_query);
dN_dphi_grid = (phi_query(1:end-1) + phi_query(2:end))/2;

figure;
hold on;
for i=1:n_limb_plot
    plot(dN_dphi_grid,dN_dphi_g(:,i));
end
ylabel('dN/d\phi [N/rad]');
xlabel(['Phase \phi_ ' num2str(i_limb) ' [rad]']);
xticks(pi/2*[0:4])
xticklabels(pi_label_list);
xlim([0 2*pi]);
legend(legend_list);


%%
% figure;
% hold on;
% for i=1:n_limb
%     plot(dN_dphi_grid,dN_dphi_g(:,i));
% end
% 
% 
hip_motors = limb_ids(:,2);
weights_lcz = weights_robotis{parms.n_twitches}(3*[1:parms.n_lc],:);
weights_lcz = fuse_weights_sym_direction(weights_lcz,parms);
weights_lcz_hip = weights_lcz(:,hip_motors);

weights_lcz_hip_selected = weights_lcz(:,i_limb)/10^3; 
%/10^3 because alpha_dot was in pos/ms during the learning and N_dot in N/s

dalpha_dphi = get_dalpha(dN_dphi_grid, parms_locomotion.amplitude_class2_deg, changeDir(i_limb,2));



figure;
colors = lines(n_limb_plot);
hold on;
for i=1:n_limb_plot
    plot(dN_dphi_grid,dN_dphi_g(:,i),'Color',colors(i,:),'LineStyle','-');
end
for i=1:n_limb_plot
    plot(dN_dphi_grid,weights_lcz_hip_selected(i,1)*dalpha_dphi,'Color',colors(i,:),'LineStyle','--');
end
ylabel('dN/d\phi [N/rad]');
xlabel(['Phase \phi_ ' num2str(i_limb) ' [rad]']);
xticks(pi/2*[0:4])
xticklabels(pi_label_list);
xlim([0 2*pi]);
legend(legend_list);


function dalpha_dphi = get_dalpha(phase, amp, changeDir)
sign_corr = 2*changeDir + 1; %-1 if changeDir =1, +1 if changeDir =0;
dalpha_dphi =  3.4113 * amp * cos(phase) * sign_corr;
end

