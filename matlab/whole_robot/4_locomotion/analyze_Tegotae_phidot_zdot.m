clear; close all; clc;
addpath('../2_load_data_code');



%% use gait plot to pick t start and t stop
%%%%% quad
recordID = 108; %142; 
n_limb = 4;
t_start = 40;
t_stop = 50;


%%
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
parms_locomotion.frequency = 0.5;

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


%% computing Tegotae feedback terms values
GRF_advanced_term = (inverse_map*GRF')';
advanced_Tegotae_term_split = zeros([size(GRF_advanced_term) n_limb]);
advanced_Tegotae_term_split_without_cos = zeros([size(GRF_advanced_term) n_limb]);

for i_limb_contrib=1:n_limb
    for i_limb_controlled=1:n_limb
        advanced_Tegotae_term_split(:,i_limb_controlled,i_limb_contrib) = ...
            sigma_advanced *inverse_map(i_limb_controlled,i_limb_contrib)*GRF(:,i_limb_contrib) .*cos(phi(:,i_limb_controlled));
        advanced_Tegotae_term_split_without_cos(:,i_limb_controlled,i_limb_contrib) = ...
            sigma_advanced *inverse_map(i_limb_controlled,i_limb_contrib)*GRF(:,i_limb_contrib) .* sign(cos(phi(:,i_limb_controlled)));
    end
end

for i=1:n_limb
    simple_Tegotae(:,i) = -0.1*GRF(:,i).*cos(phi(:,i));
    advanced_Tegotae(:,i) = sigma_advanced * GRF_advanced_term(:,i) .*cos(phi(:,i));
    advanced_Tegotae_without_cos(:,i) = sigma_advanced * GRF_advanced_term(:,i).*sign(cos(phi(:,i)));
end

% advanced_Tegotae_dot = sigma_advanced*(inverse_map*N_dot')';
% advanced_Tegotae_dot_filtered = sigma_advanced*(inverse_map*N_dot_filtered')';


max(max(abs(advanced_Tegotae-sum(advanced_Tegotae_term_split,3))))



%% contributions limb to advanced Tegotae
i_limb_plot = 2;
time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
[~,index_start] = min(abs(time-t_start));
[~,index_stop] = min(abs(time-t_stop));
dot_size = 15;

figure;
sgtitle(['Limb ' num2str(i_limb_plot) ' between ' num2str(t_start) 's and ' num2str(t_stop) 's']);
subplot(2,2,1);
title('Advanced Tegotae with cos');
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
ylabel('Contributions to phi dot','Interpreter','tex');
ylim(1.1*[-1 1]);
grid on;

subplot(2,2,2);
title('Advanced Tegotae with sign flip');
hold on;
for i=1:n_limb
    scatter(phi(index_start:index_stop,i_limb_plot),advanced_Tegotae_term_split_without_cos(index_start:index_stop,i_limb_plot,i),dot_size,'filled');
    legend_list{i} = ['Contribution limb ' num2str(i)];
end
scatter(phi(index_start:index_stop,i_limb_plot),sum(advanced_Tegotae_term_split_without_cos(index_start:index_stop,i_limb_plot,:),3),dot_size,'filled');
legend_list{n_limb+1} = 'Total';
scatter(phi(index_start:index_stop,i_limb_plot),phi_dots(index_start:index_stop,i_limb_plot),dot_size,'k','filled');
legend_list{n_limb+2} = 'Phi dot - \omega';

legend(legend_list);
xticks(pi/2*[0:4]);
xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
xlabel('\phi_{ref}');
ylabel('Contributions to phi dot','Interpreter','tex');
ylim(1.1*[-1 1]);
grid on;

subplot(2,2,3);
hold on;
for i=1:n_limb
    phi_temp = phi(index_start:index_stop,i_limb_plot);
    feedback_term = advanced_Tegotae_term_split(index_start:index_stop,i_limb_plot,i);
    scatter(phi_temp,z_dot_estimate(phi_temp,feedback_term),dot_size,'filled');
    legend_list{i} = ['Contribution limb ' num2str(i)];
end
scatter(phi(index_start:index_stop,i_limb_plot),z_dot_estimate(phi(index_start:index_stop,i_limb_plot),phi_dots(index_start:index_stop,i_limb_plot)),dot_size,'k','filled');
legend_list{n_limb+1} = 'z dot estimate (from phi dot - \omega)';

legend(legend_list);
xticks(pi/2*[0:4]);
xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
xlabel('\phi_{ref}');
ylabel('Contributions to z dot','Interpreter','tex');
ylim(1.1*[-1 1]);
grid on;

subplot(2,2,4);
total = 0;
hold on;
for i=1:n_limb
    phi_temp = phi(index_start:index_stop,i_limb_plot);
    feedback_term = advanced_Tegotae_term_split_without_cos(index_start:index_stop,i_limb_plot,i);
    scatter(phi_temp,z_dot_estimate(phi_temp,feedback_term),dot_size,'filled');
    total = total + z_dot_estimate(phi_temp,feedback_term);   
    legend_list{i} = ['Contribution limb ' num2str(i)];
end
scatter(phi(index_start:index_stop,i_limb_plot),total,dot_size,'filled');
legend_list{n_limb+1} = 'Total';
scatter(phi(index_start:index_stop,i_limb_plot),z_dot_estimate(phi(index_start:index_stop,i_limb_plot),phi_dots(index_start:index_stop,i_limb_plot)),dot_size,'k','filled');
legend_list{n_limb+2} = 'z dot estimate (from phi dot - \omega)';


legend(legend_list);
xticks(pi/2*[0:4]);
xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
xlabel('\phi_{ref}');
ylabel('Contributions to z dot','Interpreter','tex');
ylim(1.1*[-1 1]);
grid on;


%% GRFs
figure;
title(['Reference for phase : Limb ' num2str(i_limb_plot) ' between ' num2str(t_start) 's and ' num2str(t_stop) 's']);
hold on;

for i=1:n_limb
    scatter(phi(index_start:index_stop,i_limb_plot),GRF(index_start:index_stop,i),dot_size,'filled');
    legend_list{i} = ['GRF ' num2str(i)];
end

legend(legend_list);
xlabel('\phi_{ref}');
xticks(pi/2*[0:4]);
xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
ylim([-1 9]);
ylabel('GRF [N]');
grid on;


function z_dot = z_dot_estimate(phi,phi_dot)
z_dot = phi_dot.*cos(phi);
end
