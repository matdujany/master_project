close all; clc; clear;

addpath('../2_load_data_code');
addpath('../3_hebbian_learning');
addpath('../4_locomotion');

recordID = 258;
duration_per_limb = 40; %in seconds

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
if ismember(recordID,[257:261])
    flag_CS = false;
end

if flag_CS
    recordID_learning = 149;

else
    recordID_learning = 144; %110; 
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
flagPlot = false;

for i_limb_moving = 1:6
    [dN_dphi_temp,dN_dphi_grid, profile_spline_N_temp] = compute_dN_dphi(i_limb_moving,time,phi,GRF,duration_per_limb,flagPlot);
    dN_dphi(:,:,i_limb_moving) = dN_dphi_temp;
    profile_spline_N(:,i_limb_moving) = profile_spline_N_temp;
end

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

%/10^3 because alpha_dot was in pos/ms during the learning and N_dot in N/s

n_limb_plot = 6;
pi_label_list = {'0','\pi/2','\pi','3\pi/2','2\pi'};
figure;
colors = lines(n_limb_plot);
for i_limb_ref = 1:n_limb
    dalpha_dphi = get_dalpha(dN_dphi_grid, parms_locomotion.amplitude_class2_deg, changeDir(i_limb_ref,2));
    weights_lcz_hip_selected = weights_lcz_hip(:,i_limb_ref)/10^3; 
    subplot(2,n_limb/2,i_limb_ref)
    hold on;
    for i=1:n_limb_plot
        plot(dN_dphi_grid,dN_dphi(:,i,i_limb_ref),'Color',colors(i,:),'LineStyle','-');
        legend_list{i} = ['N ' num2str(i)];
    end
    for i=1:n_limb_plot
        plot(dN_dphi_grid,weights_lcz_hip_selected(i,1)*dalpha_dphi,'Color',colors(i,:),'LineStyle','--');
    end
    ylabel('dN/d\phi [N/rad]');
    xlabel(['Phase \phi_ ' num2str(i_limb_ref) ' [rad]']);
    xticks(pi/2*[0:4])
    xticklabels(pi_label_list);
    xlim([0 2*pi]);
    legend(legend_list);
end

figure;
phi_query = linspace(-1,2*pi+1,200)';
for i_limb_ref = 1:n_limb
    subplot(2,n_limb/2,i_limb_ref)
    hold on;
    for i=1:n_limb
        N_guessed_from_grid = ppval(profile_spline_N(i,i_limb_ref),phi_query);
        plot(phi_query,N_guessed_from_grid);
    end
    xlabel(['Phase \phi_ ' num2str(i_limb_ref) ' [rad]']);
    xticks(pi/2*[0:4])
    xticklabels(pi_label_list);
    xlim([0 2*pi]);
    ylabel('GRF [N]');
    title('Spline approximation');
    legend(legend_list);
end

%% LC2, motor 9 (hip of limb1).
t_start = 0;
t_stop = duration_per_limb;
figure;
hold on;
plot(time,pos_phi_data.motor_position(hip_motors(2),:));
yyaxis right;
plot(time,GRF(:,2));


function dalpha_dphi = get_dalpha(phase, amp, changeDir)
sign_corr = -2*changeDir + 1; %-1 if changeDir =1, +1 if changeDir =0;
dalpha_dphi =  3.413 * amp * cos(phase) * sign_corr;
end
