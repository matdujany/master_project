clear; close all; clc;
addpath('../2_load_data_code');



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

%% plotting parameters
i_limb_plot = 2;
time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
[~,index_start] = min(abs(time-t_start));
[~,index_stop] = min(abs(time-t_stop));
dot_size = 15;


%% computing Tegotae feedback terms values

if compute_tegotae_advanced
    
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion,n_limb,recordID);
[inverse_map,sigma_advanced] = load_inverse_map(parms_locomotion.direction,parms_locomotion.id_map_used);

[simple_Tegotae, advanced_Tegotae, advanced_Tegotae_term_split] = compute_GRF_advanced_split(GRF,phi,inverse_map,sigma_advanced);
max(max(abs(advanced_Tegotae-sum(advanced_Tegotae_term_split,3))))


%% contributions limb to advanced Tegotae
figure;
title(['Limb ' num2str(i_limb_plot) ' between ' num2str(t_start) 's and ' num2str(t_stop) 's']);
hold on;
for i=1:n_limb
    scatter(phi(index_start:index_stop,i_limb_plot),advanced_Tegotae_term_split(index_start:index_stop,i_limb_plot,i),dot_size,'filled');
    legend_list{i} = ['Contribution limb ' num2str(i)];
end
scatter(phi(index_start:index_stop,i_limb_plot),phi_dots(index_start:index_stop,i_limb_plot),dot_size,'k','filled');
legend_list{n_limb+1} = 'Phi dot - \omega';
legend(legend_list);
xticks(pi/2*[0:4]);
xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
xlabel('\phi_{ref}');

ylim(1.1*[-1 1]);
grid on;

end

%% subplots 
i_limb_plot = 2;

figure;
subplot(2,3,1);
% GRFs
plot_grf_phase(i_limb_plot,phi,GRF,index_start,index_stop,dot_size,t_start,t_stop);

subplot(2,3,2);
% Ncosphi
plot_Ncosphi(i_limb_plot,phi,GRF,index_start,index_stop,dot_size,t_start,t_stop);

subplot(2,3,3);
% Ndots
plot_Ndots(i_limb_plot,phi,N_dot_filtered,index_start,index_stop,dot_size,t_start,t_stop);

subplot(2,3,4);
% N N_horz
plot_N_Nhorz(i_limb_plot,phi,GRF,GRP,index_start,index_stop,dot_size,t_start,t_stop);

subplot(2,3,5);
% N N_dot_ref
plot_N_signcosphi(i_limb_plot,phi,GRF,index_start,index_stop,dot_size,t_start,t_stop);

subplot(2,3,6);
% N N_dot_ref
plot_N_Ndotref(i_limb_plot,phi,GRF,N_dot_filtered,index_start,index_stop,dot_size,t_start,t_stop)