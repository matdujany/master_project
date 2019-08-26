%gait plot

clear; close all; clc;
addpath('../2_load_data_code');
addpath('../../export_fig');
addpath('functions_centralization');

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

%%
recordID = 127;
n_limb = 6;

[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
parms_locomotion = add_parms_change_recordings(parms_locomotion,recordID);

for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
%     GRP(:,i) = data.float_value_time{1,i}(:,2);
end

%%
time_phi = pos_phi_data.phi_update_timestamp/10^3;

%%

margin_indexes = 60;
[idx_start_walk,idx_end_walk] = compute_start_end_walk(GRF,time_phi,margin_indexes);


%% selecting sequence - check time 
sequence_selected = 3;
indexes_sequence = [idx_start_walk(sequence_selected):idx_end_walk(sequence_selected)];

%% selecting limb
i_limb = 1;
% figure;
% subplot(2,1,1);
% plot(time_phi(indexes_sequence),pos_phi_data.limb_phi(i_limb,indexes_sequence));
% subplot(2,1,2);
% plot(time_phi(indexes_sequence),mean(pos_phi_data.limb_phi(:,indexes_sequence),1));

leg_liftoff = sin(pos_phi_data.limb_phi); 
leg_liftoff(leg_liftoff<0) = 0.1*leg_liftoff(leg_liftoff<0);


%% extracting phase

% signal_phase_extraction = mean(pos_phi_data.limb_phi(:,indexes_sequence),1);
signal_phase_extraction = mean(leg_liftoff(:,indexes_sequence),1);
[extracted_phase,end_strides] = extract_phase(signal_phase_extraction,time_phi(indexes_sequence),parms);

%% picking signals and plot
CS = GRF(indexes_sequence,i_limb);
LS = leg_liftoff(i_limb,indexes_sequence);
GS = mean(leg_liftoff(:,indexes_sequence),1);

figure;
subplot(4,1,1);
plot(time_phi(indexes_sequence),CS);
ylabel('Control Signal - GRF limb');
subplot(4,1,2);
plot(time_phi(indexes_sequence),LS);
ylabel('Local Signal - Limb liftoff');
subplot(4,1,3);
plot(time_phi(indexes_sequence),GS);
ylabel('Global Signal - Average limb liftoff');
subplot(4,1,4);
plot(time_phi(indexes_sequence),extracted_phase);
ylabel('Extracted Phase');


%% slicing
nb_strides = length(end_strides);
if sum(abs(diff(end_strides) - end_strides(1)*ones(length(end_strides)-1)))>0
    disp('Pb with number of samples per stride');
    return;
end
nb_sample_per_stride = end_strides(1);

CS_sliced = slice(CS,nb_strides,nb_sample_per_stride);
LS_sliced = slice(LS,nb_strides,nb_sample_per_stride);
GS_sliced = slice(GS,nb_strides,nb_sample_per_stride);

%% pca
[coeff,score,latent,tsquared,explained,mu] = pca(CS_sliced);
% Rows of X correspond to observations and columns correspond to variables
figure;
plot(coeff(:,1));
