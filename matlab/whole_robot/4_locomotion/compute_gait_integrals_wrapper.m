function [integrals_GRF_ref_squared, integrals_squared_GRP] = compute_gait_integrals_wrapper(recordID,first_peak_integral,last_peak_integral,GRF_ref)

addpath('../2_load_data_code');

%%
index_limb_phase = 1;

[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
parms_locomotion = add_parms_change_recordings(parms_locomotion,recordID);

n_limb = size(data.time,2)-1;

if nargin == 3
    GRF_ref = zeros(1,n_limb);
end 

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

%% integrals
phi = pos_phi_data.limb_phi;
[~,idx_peaks]=findpeaks(phi(index_limb_phase,:));

indexes_integral = idx_peaks(first_peak_integral)+1:idx_peaks(last_peak_integral);

index_check= find(sum(GRF(indexes_integral,:),2) < 10);
if ~isempty(index_check)
    disp('Warning ! the indexes selected contain samples where the robot is in the air');
    return;
end

%%
[~,~,~,integrals_GRF_ref_squared] = compute_gait_integrals(indexes_integral,GRF,GRF_ref,data.time);

[~,integrals_squared_GRP,~,~] = compute_gait_integrals(indexes_integral,GRP,zeros(1,n_limb),data.time);
end