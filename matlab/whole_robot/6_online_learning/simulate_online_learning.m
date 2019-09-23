%here we start from a map of weights learnt from twitching and we simulate
%an online learning, using the data captured during a locomotion
%experiment, with the map learnt with twitching to synchronize the limbs.

clear; close all; clc;
addpath('../2_load_data_code');
addpath(genpath('../3_hebbian_learning'));
addpath(genpath('../4_locomotion'));

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

%%
recordID_locomotion = 34; %148
n_limb = 6;
t_start = 60;
t_stop = 110;

% recordID_locomotion = 108; %148
% n_limb = 4;
% t_start = 10;
% t_stop = 80;

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
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion.direction,n_limb,recordID_weights);

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

n_pos_check = sum(sum(abs(pos-512)>150));
disp([num2str(n_pos_check) ' samples out of reasonable limits for motor position (+-150)']);
for i=1:size(pos,2)
    index_nan = find(abs(pos(:,i)-512)>150);
    pos(index_nan,i) = mean(pos([index_nan-1 index_nan+1],i));
end

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

[~, index_start] = min(abs(time_lc(:,1)-t_start));
[~, index_stop] = min(abs(time_lc(:,1)-t_stop));

%%
total_load = sum(GRF,2);
margin_index_total = 30;
total_load_min = zeros(size(total_load));
for i=1+margin_index_total:length(total_load_min)-margin_index_total
    total_load_min(i,1) = min(total_load(i-margin_index_total:i+margin_index_total));
end

figure;
hold on;
plot(total_load_min(index_start:index_stop));
plot(total_load(index_start:index_stop));

%%
threshold_load = 0.8; %in N
pos_dot_corrected_learning = zeros(size(pos_dot));
for i=1:n_limb
    for j=1:2
        pos_dot_corrected_learning(:,limb_ids(i,j))= pos_dot(:,limb_ids(i,j))...
            .*(GRF_filtered(2:end,i)>threshold_load).*(total_load_min(2:end)>10);
    end
end

weights_init = weights_robotis{5}(1:3*parms.n_lc,:);
weights_init_fused = fuse_weights_sym_direction(weights_init,parms);

h_lcz = plot_hinton_lc_limb_order(weights_init_fused,limb,parms);

weights_lcz_init = weights_init_fused(3*[1:parms.n_lc],:);


%%

weights_online = zeros(index_stop-index_start+1,parms.n_lc,parms.n_m);
learning_rate_online = 1;
for i=1:parms.n_m
    weights_online(:,:,i) = compute_weight_detailled_evolution_helper(....
        pos_dot_corrected_learning(index_start:index_stop,i), GRF_dot(index_start:index_stop,:), ...
        learning_rate_online, weights_lcz_init(:,i)');
end
    
hip_motors = limb(:,1);

%%
figure;
for i_limb=1:n_limb
    subplot(2,n_limb/2,i_limb);
    hold on;
    for i=1:parms.n_lc
        plot(weights_online(:,i,hip_motors(i_limb)));
        legend_list{i} = ['LC ' num2str(i)];
    end
    legend(legend_list);
    title(['Hip motor, Limb ' num2str(i_limb)]);
end

%%
weights_online_final = squeeze(mean(weights_online(end-50:end,:,:),1));

%%
% figure;
weights_init_for_map = weights_lcz_init(:,hip_motors)/max(max(abs(weights_lcz_init(:,hip_motors))));
weights_final_for_map = weights_online_final(:,hip_motors)/max(max(abs(weights_online_final(:,hip_motors))));

for i=1:n_limb
    if changeDir(i,2) == 1
        weights_init_for_map(:,i) = -weights_init_for_map(:,i);
        weights_final_for_map(:,i) = -weights_final_for_map(:,i);
    end
end
inv_map_init = weights_init_for_map';
inv_map_online = weights_final_for_map';

h_invmap_online = plot_lc_to_limb_inv_map(inv_map_online,parms);


h_invmap_init = plot_lc_to_limb_inv_map(inv_map_init,parms);

%%
if parms.n_m == 8
    disp ('Inverse map online:'); fprintf('{%.3f, %.3f, %.3f, %.3f} ,\n',inv_map_online);
end
if parms.n_m == 12
    disp ('Inverse map online:'); fprintf('{%.3f, %.3f, %.3f, %.3f, %.3f, %.3f} ,\n',inv_map_online);
end
if parms.n_m == 16
    disp ('Inverse map online:'); fprintf('{%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f} ,\n',inv_map_online);
end


%%
% save('inv_maps_online/test2','inv_map_online','recordID_locomotion','learning_rate_online','t_start','t_stop');
