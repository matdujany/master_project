%gait plot

clear; close all; clc;
addpath('../2_load_data_code');
addpath('plot_functions');

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

%%
recordID = 304; %148

[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
n_limb = size(data.time,2)-1;

[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion.direction,n_limb,recordID);

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

time_GRF = (data.time(:,:)-data.time(1,:))/10^3;
time_GRF_mean = mean(time_GRF,2);

%% phases
time_phases = pos_phi_data.phi_update_timestamp(1,:)/10^3;
[f_phase,ax_phase] = plot_phases(pos_phi_data,recordID,GRF,time_GRF(:,1));

%% delta phases
phi = pos_phi_data.limb_phi;
delta_phases = compute_delta_phases(phi);
time_phase = pos_phi_data.phi_update_timestamp(1,:)/10^3;
[f_delta_phases,ax_delta_phases] = plot_delta_phases(time_phase,delta_phases,recordID);
phi = phi';

%%
t_start = [30 67 104.5];
t_stop = [45 90 119];
i_limb_ref = 3;


GRF_sel = [];
phi_sel = [];
time_phi_sel = [];

for k=1:length(t_start)
    [~,idx1] = min( abs(time_phase-t_start(k)) );
    [~,idx2] = min( abs(time_phase-t_stop(k)) );
    GRF_sel = [GRF_sel; GRF(idx1:idx2,:)];
    phi_sel = [phi_sel; phi(idx1:idx2,:)];
    time_phi_sel = [time_phi_sel time_phase(idx1:idx2)];
end


%%
flag_same_ref = false;

[limb_list_ordered,limb_names_ordered] = get_limb_list_names(n_limb,recordID);
limb_list_ordered = [limb_list_ordered(n_limb/2+1:end);limb_list_ordered(1:n_limb/2)];
limb_names_ordered = {limb_names_ordered{n_limb/2+1:end} limb_names_ordered{1:n_limb/2}};
figure;
for i=1:n_limb
    subplot(2,n_limb/2,i)
    if flag_same_ref
        scatter(phi_sel(:,i_limb_ref),GRF_sel(:,limb_list_ordered(i)));
        xlabel(['Phase \phi_' num2str(i_limb_ref) ' [rad]']);
    else
        scatter(phi_sel(:,limb_list_ordered(i)),GRF_sel(:,limb_list_ordered(i)));
        xlabel(['Phase \phi_' num2str(limb_list_ordered(i)) ' [rad]']);
    end
    ylim([-1 11]);
    ylabel([limb_names_ordered{i} ' - Limb ' num2str(limb_list_ordered(i)) ' - GRF [N]']);
    pi_label_lists = {'0','1/2\pi','\pi','3/2\pi','2\pi'};
    xticklabels(pi_label_lists);
    xticks(pi/2*[0:4]);
    xlim([0 2*pi]);
end

%%
[pk_values,idx_peaks]=findpeaks(phi_sel(:,i_limb_ref));

is_cycle = ones(length(idx_peaks)-1,1);
for i=1:length(idx_peaks)-1
    duration_cycle = time_phi_sel(idx_peaks(i+1))-time_phi_sel(idx_peaks(i));
    if abs(duration_cycle - 1/parms_locomotion.frequency)>0.2
        is_cycle(i,1) = 0;
    end
end

figure;
hold on;
plot(time_phi_sel,phi_sel(:,i_limb_ref));
scatter(time_phi_sel(idx_peaks),pk_values,'ko','HandleVisibility','off');

n_cycles = sum(is_cycle);
disp(['Number of cycles ' num2str(n_cycles)]);

max_length_gc = max(diff(idx_peaks));
all_phi_ref = nan(max_length_gc,n_cycles);
all_GRFs = nan(max_length_gc,n_cycles,n_limb);
all_times = nan(max_length_gc,n_cycles);
length_cycles = zeros(n_cycles,1);
idx_temp = 0;
for i=1:length(idx_peaks)-1
    if is_cycle(i)
        idx_temp = idx_temp + 1;
        length_cycles(idx_temp,1) = idx_peaks(i+1)-idx_peaks(i);
        all_phi_ref(1:length_cycles(idx_temp,1),idx_temp) = phi_sel(idx_peaks(i)+1:idx_peaks(i+1),i_limb_ref);
        all_GRFs(1:length_cycles(idx_temp,1),idx_temp,:) = GRF_sel(idx_peaks(i)+1:idx_peaks(i+1),:);
        all_times(1:length_cycles(idx_temp,1),idx_temp) = time_phi_sel(idx_peaks(i)+1:idx_peaks(i+1));
    end
end
all_times_recentered = all_times - all_times(1,:);
time_offset_estimation = all_phi_ref(1,:)/(parms_locomotion.frequency*2*pi);
all_times_recentered = all_times_recentered + time_offset_estimation;
all_times_rescaled = zeros(size(all_times_recentered));
for k=1:n_cycles
    all_times_rescaled(:,k) = 100*all_times_recentered(:,k)/all_times_recentered(length_cycles(k),k);
end

%%
flag_rescale_time = true;

colors = parula(n_cycles);
f=figure;
f.Color = 'w';
for i=1:n_limb
    subplot(2,n_limb/2,i)
    hold on;
    if flag_rescale_time
        for k=1:n_cycles
            xdata = all_times_rescaled(:,k);
            plot(xdata,all_GRFs(:,k,limb_list_ordered(i)),'Color',colors(k,:));
        end
        xlabel('% of gait cycle');
    else
        for k=1:n_cycles
            xdata = all_times_recentered(:,k);
            plot(xdata,all_GRFs(:,k,limb_list_ordered(i)),'Color',colors(k,:));
        end
        xlabel('Time [s]');
    end
    ylim([-1 11]);
    ylabel([limb_names_ordered{i} ' - Limb ' num2str(limb_list_ordered(i)) ' - GRF [N]']);
    ax=gca();
    ax.FontSize = fontSizeTicks;
    ax_f(i,1) = ax;
    grid on;
end
linkaxes(ax_f,'x');

%%
n_values = 100;
grid_gait_cycle = linspace(0,100,n_values+1);
GRF_profile = zeros(n_values,n_limb);
for i=1:n_values
    temp_data_for_mean = [];
    for k=1:n_cycles
        temp_data_for_mean = [temp_data_for_mean; all_GRFs( grid_gait_cycle(i)<all_times_rescaled(:,k) & all_times_rescaled(:,k)<=grid_gait_cycle(i+1),k,:)];
    end
    GRF_profile(i,:) = mean(temp_data_for_mean,1);
end
time_gait_cycle = (grid_gait_cycle(1:end-1)+grid_gait_cycle(2:end))/2;

f=figure;
f.Color = 'w';
for i=1:n_limb
    subplot(2,n_limb/2,i)
    plot(time_gait_cycle,GRF_profile(:,limb_list_ordered(i)));
    xlabel('% of gait cycle');
    ylim([-1 11]);
    ylabel([limb_names_ordered{i} ' - Limb ' num2str(limb_list_ordered(i)) ' - GRF [N]']);
    ax=gca();
    ax.FontSize = fontSizeTicks;
    ax_f(i,1) = ax;
    grid on;
end
linkaxes(ax_f,'x');