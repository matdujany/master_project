
clear; close all; clc;
addpath('../2_load_data_code');

%%
recordID1 = 218; %bipod, maximizing N^2 from all in phase initial conditions
ax_sum1 = plot_sums(recordID1);
sgtitle(['record ' num2str(recordID1)]);

recordID2 = 211; %211; %from bipod initial conditions, minimizing N^2 --> they all go in phase
x_sum2 = plot_sums(recordID2);
sgtitle(['record ' num2str(recordID2)]);

function ax_sum = plot_sums(recordID)

[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);
n_limb =size(data.time,2)-1;

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

time = (data.time(:,1)-data.time(1,1))/10^3;

% GRF = GRF_filtered;
ax_sum = zeros(2,1);
figure;
subplot(1,2,1);
plot(time, sum(GRF_filtered.^2,2));
ax_sum(1,1)=gca();
xlabel('Time [s]');
ylabel('Sum GRF^2 [N^2]');
ylim([0 250]);
subplot(1,2,2);
plot(time, sum(GRP_filtered.^2,2));
ax_sum(2,1)=gca();
xlabel('Time [s]');
ylabel('Sum GRP^2 [N^2]');
end
