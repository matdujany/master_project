clear; close all; clc;
addpath('../2_load_data_code');
addpath('../3_hebbian_learning');



%% use gait plot to pick t start and t stop
%%%%% quad
recordID = 108; 
n_limb = 4;
t_start = 15;
t_stop = 25;

%%%% hexa
% recordID = 34; %139: n dot %132 hardcoded bipod
% n_limb = 6;
% t_start = 56;
% t_stop = 70;

%%%% octo
% recordID = 50;
% disp('Warning! Pb with phase locking of limb 1');
% n_limb = 8;
% t_start = 60;
% t_stop = 76;

compute_tegotae_advanced = true;

%%
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
parms_locomotion.frequency = 0.5;

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
%     GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i)); %causal
    GRF_filtered(:,i) = filtfilt(filter_coeffs,1,GRF(:,i)); %non-causal
end

%%
order = 2;
framelen = 15;
% GRF_filtered = sgolayfilt(GRF,order,framelen);

threshold_unloading = 0.2; %Fukuhuara, figure 6, stance if more than 20% of maximal value
[value_unloading,max_value_GRF_limb] = determine_value_unloading(GRF,threshold_unloading);

%% computing N_dots
for i=1:n_limb
    N_dot(:,i) = 10^3*diff(GRF(:,i))./diff(data.time(:,i));
    N_dot_filtered(:,i) = 10^3*diff(GRF_filtered(:,i))./diff(data.time(:,i));
end

%% computing phase updates
phi_dots = zeros(size(phi)-[1 0]);
diff_phi = diff(phi);
diff_phi(diff_phi<-6) = diff_phi(diff_phi<-6)+2*pi;
for i=1:n_limb
    phi_dots(:,i) = 10^3*diff_phi(:,i)./diff(pos_phi_data.phi_update_timestamp)' - 2*pi*parms_locomotion.frequency;
%     phase_updates(:,i) = diff_phi(:,i)./0.021 - 2*pi*parms_locomotion.frequency;

end


%% motor positions
pos = pos_phi_data.motor_position';
pos_filtered = filtfilt(filter_coeffs,1,pos);

pos_dots = zeros(size(pos)-[1 0]);
for i=1:n_limb
    pos_dots(:,i) = 10^3*diff(pos_filtered(:,i))./diff(pos_phi_data.phi_update_timestamp)';
end


%% time extraction
time = (data.time(:,1)-data.time(1,1))/10^3;
[~,index_start] = min(abs(time-t_start));
[~,index_stop] = min(abs(time-t_stop));

% N_extracted = GRF(index_start:index_stop,:);
N_extracted = GRF_filtered(index_start:index_stop,:);
N_dot_extracted = N_dot_filtered(index_start:index_stop,:);
pos_dot_extracted = pos_dots(index_start:index_stop,:);
phi_dot_extracted = phi_dots(index_start:index_stop,:);
phi_extracted = phi(index_start:index_stop,:);

%%
i_limb_ref_phi = 1;
figure;
subplot(1,3,1);
legend_list = cell(n_limb,1);
hold on;
for i=1:n_limb
scatter(phi_extracted(:,i_limb_ref_phi),N_extracted(:,i));
legend_list{i} = ['Limb ' num2str(i)];
end
ylabel('N');
xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
legend(legend_list);
subplot(1,3,2);
hold on;
for i=1:n_limb
scatter(phi_extracted(:,i_limb_ref_phi),N_dot_extracted(:,i));
end
xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
ylabel('dN/dt');
legend(legend_list);

subplot(1,3,3);
hold on;
for i=1:n_limb
scatter(phi_extracted(:,i_limb_ref_phi),phi_dot_extracted(:,i));
end
ylabel('phi dot');
xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
legend(legend_list);

%%
grid_phi = linspace(0,2*pi,50);
Ndot_grid = zeros(length(grid_phi)-1,n_limb);
phidot_grid = zeros(length(grid_phi)-1,n_limb);
phi_grid = zeros(length(grid_phi)-1,n_limb);

% alphadot_grid = zeros(length(grid_phi)-1,n_limb);
grid_phi_x = (grid_phi(1,1:end-1) + grid_phi(1,2:end))/2;

for i=1:length(grid_phi)-1
    %     idx = find(grid_phi(i)<phi & phi<grid_phi(i+1));
    idx_tmp = grid_phi(i)<phi_extracted(:,i_limb_ref_phi) & phi_extracted(:,i_limb_ref_phi)<grid_phi(i+1);
    Ndot_grid(i,:) = mean(N_dot_extracted(idx_tmp,:),1);
    phidot_grid(i,:) = mean(phi_dot_extracted(idx_tmp,:),1);
    phi_grid(i,:) = mean(phi_extracted(idx_tmp,:),1);
end

%%
figure;
for i=1:n_limb
    subplot(2,n_limb/2,i);
    plot(grid_phi_x,Ndot_grid(:,i));
    ylabel('N dot');
    xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
    title(['Limb ' num2str(i)]); 
end

figure;
for i=1:n_limb
    subplot(2,n_limb/2,i);
    plot(grid_phi_x,phidot_grid(:,i));
    ylabel('Phi dot');
    xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
    title(['Limb ' num2str(i)]); 
end

figure;
for i=1:n_limb
    subplot(2,n_limb/2,i);
    plot(grid_phi_x,phi_grid(:,i));
    ylabel('Phi');
    xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
    title(['Limb ' num2str(i)]); 
end

%%
N_dot_est = zeros(size(Ndot_grid));

switch n_limb
    case 4
        recordID_weights = 105;
        [~, ~, parms] = load_data_processed(recordID_weights);
    case 6
        recordID_weights = 110;
        [~, ~, parms] = load_data_processed(recordID_weights);
    otherwise
        disp('add maps for this number of limb');
end

weights_robotis = read_weights_robotis(recordID_weights,parms);
weights_lcz = weights_robotis{parms.n_twitches}(3*[1:parms.n_lc],:);
weights_lcz = fuse_weights_sym_direction(weights_lcz,parms);

[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values("X",n_limb,recordID);

hip_motors = limb_ids(:,2);

weights_sign_corrected = weights_lcz(:,hip_motors);
for i=1:length(hip_motors)
    if changeDir(i,2) == 1
        weights_sign_corrected(:,i) = - weights_sign_corrected(:,i);
    end
end

%%

for i_lc=1:n_limb
    for j_motor=1:n_limb
        N_dot_est(:,i_lc) = N_dot_est(:,i_lc) + weights_sign_corrected(i_lc,j_motor)*cos(phi_grid(:,j_motor)).*phidot_grid(:,j_motor);
    end
end

%%
figure;
for i=1:n_limb
    subplot(2,n_limb/2,i);
    hold on;
    plot(grid_phi_x,Ndot_grid(:,i));
    plot(grid_phi_x,N_dot_est(:,i));
    ylabel('N dot');
    xlabel(['\phi_ ' num2str(i_limb_ref_phi)]);
    title(['Limb ' num2str(i)]); 
    legend('Real','Estimated');
end
