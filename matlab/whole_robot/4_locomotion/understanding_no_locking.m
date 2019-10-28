%this is to understand why one limb does not lock with the others (cf L1 -
%limb 4- in record 250).

%gait plot

clear; close all; clc;
addpath('../2_load_data_code');
addpath('plot_functions');

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

%%
recordID = 311; %148
flag_control_in_stance_only = true;

n_limb = 6;

[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion.direction,n_limb,recordID);
n_limb = size(limbs,1);

n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);

if abs(n_samples_phi-n_samples_GRF)>1
    disp('Warning ! Number of samples dont agree');
end

GRF = zeros(n_samples_GRF,n_limb);
GRP = zeros(n_samples_GRF,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end

%filtered version:
size_mv_average = 6;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
GRF_filtered = zeros(size(GRF));
GRP_filtered = zeros(size(GRP));

for i=1:n_limb
    GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i));
    GRP_filtered(:,i) = filter(filter_coeffs,1,GRP(:,i));
end

% GRF = GRF_filtered;

%%
phi = pos_phi_data.limb_phi;
delta_phases = compute_delta_phases(phi);
time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
[f_delta_phases,ax_delta_phases] = plot_delta_phases(time,delta_phases,recordID);
xlim([0 60]);
phi = phi';

%% control terms
[u_hip,u_knee,v_hip,v_knee] = load_matrix_complete_rule_cs();

sigma_hip = parms_locomotion.sigma_hip;
sigma_knee = parms_locomotion.sigma_knee;
sigma_p_hip = parms_locomotion.sigma_p_hip;
sigma_p_knee = parms_locomotion.sigma_p_knee;

[feedback,phi_dots,check_feedback] = compute_controle_control_term(GRF,GRP,phi,pos_phi_data.phi_update_timestamp,parms_locomotion.frequency,...
    sigma_hip,sigma_knee,sigma_p_hip, sigma_p_knee,u_hip,u_knee,v_hip,v_knee,...
    flag_control_in_stance_only);

%%
figure;
hold on;
for i=1:n_limb
    plot(check_feedback(:,i));
end
title('Check that the computed feedback is actually the phase update');

%% phase plots
t_start = 50; %50;
t_stop = 80; %80;
[~,i_start] = min(abs(time-t_start));
[~,i_stop] = min(abs(time-t_stop));

figure;
for i=1:n_limb
    subplot(2,n_limb/2,i);
    scatter(phi(i_start:i_stop,i),feedback(i_start:i_stop,i));
    title(['Limb ' num2str(i)]);
    xlabel('Phase limb [rad]');
    ylabel('Sensory feedback [rad/s]');
end
sgtitle('Control');

figure;
for i=1:n_limb
    subplot(2,n_limb/2,i);
    scatter(phi(i_start:i_stop,i),phi_dots(i_start:i_stop,i));
    title(['Limb ' num2str(i)]);
    xlabel('Phase limb [rad]');
    ylabel('\dot{phi} -2*\pi*f [rad/s]');
end
sgtitle('Actual phi dot');

%%
if false
phi_249 = phi(i_start:i_stop,:);
feedback_249 = feedback(i_start:i_stop,:);
save('control_249','phi_249','feedback_249');
end