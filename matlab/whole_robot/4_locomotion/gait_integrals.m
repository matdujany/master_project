%gait plot

clear; close all; clc;
addpath('../2_load_data_code');
addpath('../../export_fig');
addpath('plot_functions');

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

%%
% recordID = 108;
% n_limb = 4;

% recordID = 34;
% n_limb = 6;

% recordID = 50;
% n_limb = 8;

% recordID = 34;
% n_limb = 6;

recordID = 167;
n_limb = 6;


[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
parms_locomotion = add_parms_change_recordings(parms_locomotion,recordID);

[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion,n_limb,recordID);
n_limb = size(limbs,1);

n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);

if abs(n_samples_phi-n_samples_GRF)>1
    disp('Warning ! Number of samples dont agree');
end

% GRF = zeros(n_samples,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end

%filtered version:
size_mv_average = 6;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
GRF_filtered = zeros(size(GRF));
for i=1:n_limb
    GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i));
end

GRF = GRF_filtered;

%%
threshold_unloading = 0.2; %Fukuhuara, figure 6, stance if more than 20% of maximal value

time_GRF = (data.time-data.time(1,:))/10^3;
[f_GRF,ax_grf] = plot_GRF(GRF,time_GRF,threshold_unloading,recordID);
[f_gait,ax_gait] = plot_gait_diagram(GRF,time_GRF,threshold_unloading,recordID);
[f_phase,ax_phase] = plot_phases(pos_phi_data,recordID);

phi = pos_phi_data.limb_phi;
delta_phases = compute_delta_phases(phi);
time_phases = pos_phi_data.phi_update_timestamp(1,:)/10^3;
[f_delta_phases,ax_delta_phases] = plot_delta_phases(time_phases,delta_phases,recordID);
linkaxes([ax_grf; ax_gait; ax_phase; ax_delta_phases],'x');


%% integrals
index_limb_phase = 1;
phi = pos_phi_data.limb_phi;
[pk_values,idx_peaks]=findpeaks(phi(index_limb_phase,:));
set(0, 'CurrentFigure', f_phase)
hold on;
time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
scatter(time(idx_peaks),pk_values,'ko','HandleVisibility','off');

first_peak_integral = 22;
last_peak_integral = 40;
scatter(time(idx_peaks(first_peak_integral)),pk_values(first_peak_integral),'ro','HandleVisibility','off');
scatter(time(idx_peaks(last_peak_integral)),pk_values(last_peak_integral),'ro','HandleVisibility','off');

indexes_integral = idx_peaks(first_peak_integral)+1:idx_peaks(last_peak_integral);

figure;
hold on;
plot(time,sum(GRF,2));
plot(time(idx_peaks(first_peak_integral))*[1 1],[0 20],'k--');
plot(time(idx_peaks(last_peak_integral))*[1 1],[0 20],'k--');


index_check= find(sum(GRF(indexes_integral,:),2) < 10);
if ~isempty(index_check)
    disp('Warning ! the indexes selected contain samples where the robot is in the air');
    return;
end

%%

integrals = sum(GRF(indexes_integral,:).*diff(data.time([indexes_integral(1)-1 indexes_integral],1:n_limb)),1) ./ ...
    (data.time(indexes_integral(end),1:n_limb) - data.time(indexes_integral(1)-1,1:n_limb));

% integrals_squared = sum(GRF(indexes_integral,:).^2,1)/length(indexes_integral);

integrals_squared = sum(GRF(indexes_integral,:).^2.*diff(data.time([indexes_integral(1)-1 indexes_integral],1:n_limb)),1) ./ ...
    (data.time(indexes_integral(end),1:n_limb) - data.time(indexes_integral(1)-1,1:n_limb));


% GRF_ref = [6,    1.5,   6,    1.5];
GRF_ref = 6*ones(1,n_limb);

% integrals_GRF_ref = sum(abs(GRF(indexes_integral,:)-GRF_ref),1)/length(indexes_integral);
integrals_GRF_ref = sum(abs(GRF(indexes_integral,:)-GRF_ref).*diff(data.time([indexes_integral(1)-1 indexes_integral],1:n_limb)),1) ./ ...
    (data.time(indexes_integral(end),1:n_limb) - data.time(indexes_integral(1)-1,1:n_limb));
integrals_GRF_ref_squared = sum((GRF(indexes_integral,:)-GRF_ref).^2.*diff(data.time([indexes_integral(1)-1 indexes_integral],1:n_limb)),1) ./ ...
    (data.time(indexes_integral(end),1:n_limb) - data.time(indexes_integral(1)-1,1:n_limb));

integrals
integrals_squared
integrals_GRF_ref
integrals_GRF_ref_squared
% metric_tracking_GRF_ref = sum(integrals_GRF_ref)