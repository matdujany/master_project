clear; close all; clc;
addpath('../2_load_data_code');

%Quad
% recordID = 108; 
% n_limb = 4;

recordID = 34; 
n_limb = 6;


[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion,n_limb,recordID);
[inverse_map,sigma_advanced] = get_inverse_map(parms_locomotion.direction,parms_locomotion.id_map_used);

n_limb = size(limbs,1);
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
    GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i));
end

threshold_unloading = 0.2; %Fukuhuara, figure 6, stance if more than 20% of maximal value
[value_unloading,max_value_GRF_limb] = determine_value_unloading(GRF,threshold_unloading);

%% computing N_dots
for i=1:n_limb
    N_dot(:,i) = 10^3*diff(GRF(:,i))./diff(data.time(:,i));
end

%% computing Tegotae feedback terms values
GRF_advanced_term = (inverse_map*GRF')';
GRF_advanced_term_dot = (inverse_map*N_dot')';

for i=1:n_limb
    simple_Tegotae(:,i) = -0.1*GRF(:,i).*cos(phi(:,i));
    advanced_Tegotae(:,i) = sigma_advanced * GRF_advanced_term(:,i) .*cos(phi(:,i));
    advanced_Tegotae_dot(:,i) = -GRF_advanced_term_dot(:,i);
end

%% plotting GRFs
i_limb_plot = 3;
time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;

xlims = [30 60]; %% in secs

f=figure;
f.Color = 'w';
sgtitle(['Limb LC ' num2str(i_limb_plot)]);

%GRF
subplot(3,1,1);
hold on;
plot([time(1) time(end)],[value_unloading(i_limb_plot) value_unloading(i_limb_plot)],'k--');
plot(time, GRF(:,i_limb_plot));
ylabel('Z Load [N]');
ylim([-2 13]);
xlim(xlims);
xlabel('Time [s]');
ax_grf=gca();
add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax_grf.YLim,time,'b');

% Ncos(phi)
subplot(3,1,2);
hold on;
plot(time, - GRF(:,i_limb_plot).*cos(phi(:,i_limb_plot)));
plot([time(1) time(end)],[0 0],'k--');
ylabel('- N * cos phi [N]');
ylim([-10 10]);
xlim(xlims);
xlabel('Time [s]');
ax_Ncosphi=gca();
add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax_Ncosphi.YLim,time,'b');

% Ndot
subplot(3,1,3);
hold on;
plot(time(2:end), N_dot(:,i_limb_plot));
plot([time(1) time(end)],[0 0],'k--');
ylabel('N\_dot [N/s]');
ylim(50*[-1 1]);
xlim(xlims);
xlabel('Time [s]');
ax_Ndot=gca();
add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax_Ndot.YLim,time,'b');

linkaxes([ax_grf ax_Ncosphi ax_Ndot],'x');

%% comparing Tegotae terms
figure;
i_limb_Tegotae = 3;
time = (data.time(:,i_limb_Tegotae)-data.time(1,i_limb_Tegotae))/10^3;
hold on;
plot(time, simple_Tegotae(:,i_limb_plot),'LineWidth',2);
plot(time, advanced_Tegotae(:,i_limb_plot),'LineWidth',2);
% legend('Simple','Advanced');

plot(time(2:end), 0.02*N_dot(:,i_limb_plot));
plot(time(2:end), 0.02*advanced_Tegotae_dot(:,i_limb_plot));
legend('Simple','Advanced','N dot','Advanced Tegotae dot');
xlim([55 70]);
ylim(2*[-1 1]);
ylabel('phase update [rad/s]');
xlabel('Time');
ax_Tegotae=gca();
add_stance_patches_GRF(GRF(:,i_limb_Tegotae),threshold_unloading,ax_Tegotae.YLim,time,'b');

linkaxes([ax_grf ax_Ncosphi ax_Ndot ax_Tegotae],'x');
