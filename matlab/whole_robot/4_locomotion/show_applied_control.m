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

phi_dots = zeros(size(phi)-[1 0]);
diff_phi = diff(phi);
diff_phi(diff_phi<-6) = diff_phi(diff_phi<-6)+2*pi;
for i=1:n_limb
    phi_dots(:,i) = 10^3*diff_phi(:,i)./diff(pos_phi_data.phi_update_timestamp)' - 2*pi*parms_locomotion.frequency;
end

%% phase plots
t_start = 50; %50;
t_stop = 80; %80;
[~,i_start] = min(abs(time-t_start));
[~,i_stop] = min(abs(time-t_stop));

figure;
for i=1:n_limb
    subplot(2,n_limb/2,i);
    scatter(phi(i_start:i_stop,i),phi_dots(i_start:i_stop,i));
    title(['Limb ' num2str(i)]);
    xlabel('Phase limb [rad]');
    ylabel('$$ \dot{\phi} -2\pi f $$ [rad/s]','FontSize',16,'Interpreter','latex');
end
sgtitle('Actual phi dot');
