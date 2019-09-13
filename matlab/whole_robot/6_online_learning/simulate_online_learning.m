clear; close all; clc;
addpath('../2_load_data_code');
addpath(genpath('../3_hebbian_learning'));

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

%%
recordID_locomotion = 34; %148
n_limb = 6;

switch n_limb
    case 4
        recordID_weights = 105;
    case 6
        recordID_weights = 110;
    otherwise
        disp('add maps for this number of limb');
end

[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID_locomotion);

weights_robotis = read_weights_robotis(recordID_weights,parms);
limb = get_good_limb(parms,recordID_weights);

n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);

if abs(n_samples_phi-n_samples_GRF)>1
    disp('Warning ! Number of samples dont agree');
end

% GRF = zeros(n_samples,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
end
time_lc = data.time(:,1:parms.n_lc)/10^3;

pos = pos_phi_data.motor_position';
time_pos = pos_phi_data.motor_timestamps'/10^3;

%filtered version:
size_mv_average = 6;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
GRF_filtered = zeros(size(GRF));
pos_filtered = zeros(size(pos));
for i=1:n_limb
    GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i));
end
for i=1:parms.n_m
    pos_filtered(:,i) = filter(filter_coeffs,1,pos(:,i));
end


GRF_dot = diff(GRF_filtered)./diff(time_lc);
pos_dot = diff(pos_filtered)./diff(time_pos)/10^3;

threshold_load = 1; %in N
pos_dot_corrected_learning = zeros(size(pos_dot));
for i=1:n_limb
    for j=1:2
        pos_dot_corrected_learning(:,limb(i,j))= pos_dot(:,limb(i,j)).*(GRF_filtered(2:end,i)>threshold_load);
    end
end

weights_init = weights_robotis{5}(1:3*parms.n_lc,:);
weights_init_fused = fuse_weights_sym_direction(weights_init,parms);

h_lcz = plot_hinton_lc_limb_order(weights_init_fused,limb,parms);

weights_lcz_init = weights_init_fused(3*[1:parms.n_lc],:);


%%
t_start = 60;
t_stop = 110;
[~, index_start] = min(abs(time_lc(:,1)-t_start));
[~, index_stop] = min(abs(time_lc(:,1)-t_stop));

weights_online = zeros(index_stop-index_start+1,parms.n_lc,parms.n_m);
learning_rate = 10;
for i=1:parms.n_m
    weights_online(:,:,i) = compute_weight_detailled_evolution_helper(....
        pos_dot_corrected_learning(index_start:index_stop,i), GRF_dot(index_start:index_stop,:), ...
        learning_rate, weights_lcz_init(:,i)');
end
    
hip_motors = limb(:,1);

%%
figure;
for i_limb=1:n_limb
    subplot(2,n_limb/2,i_limb);
    hold on;
    for i=1:parms.n_lc
        plot(weights_online(:,i,hip_motors(i_limb)));
    end
    title(['Hip motor, Limb ' num2str(i_limb)]);
end
    
    