clear; close all; clc;
addpath('../2_load_data_code');

recordID = 31;
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

n_limb = 6;
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion,n_limb,recordID);
n_limb = size(limbs,1);
n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);
if abs(n_samples_phi-n_samples_GRF)>1
    disp('Warning ! Number of samples dont agree');
end
if n_samples_phi == n_samples_GRF+1
    phi = pos_phi_data.limb_phi(:,2:end);
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


%% plotting GRFs
[limb_list_ordered,limb_names_ordered] = get_limb_list_names(n_limb,recordID);
threshold_unloading = 0.2; %Fukuhuara, figure 6, stance if more than 20% of maximal value
[value_unloading,max_value_GRF_limb] = determine_value_unloading(GRF,threshold_unloading);

plot_propulsion = false;
xlims = [0 30]; %% in secs

f_GRF=figure;
f_GRF.Color = 'w';
index_subplots = reshape(1:n_limb, 2, n_limb/2).';
ax_grf = zeros(n_limb,1);
for i=1:n_limb
    ax_grf(i,1) = subplot(n_limb/2,2,index_subplots(i));
    hold on;
    i_limb_plot = limb_list_ordered(i);
    time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
    if plot_propulsion
        plot(time, GRP(:,i_limb_plot));
        ylabel('Y Load [N]');
        ylim([-5 5]);
        
    else
        plot([time(1) time(end)],[value_unloading(i_limb_plot) value_unloading(i_limb_plot)],'k--');
        plot(time, GRF(:,i_limb_plot));
        ylabel('Z Load [N]');
        ylim([-2 13]);
    end
    xlim(xlims);
    xlabel('Time [s]');
    ax=gca();
    add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax.YLim,time,'b');
    title([limb_names_ordered{i} '  (LC ' num2str(i_limb_plot) ')']);
%     ax.FontSize = fontSizeTicks;
    grid on;
end
linkaxes(ax_grf,'x');

%% Ncos(phi)

f_Ncosphi=figure;
f_Ncosphi.Color = 'w';
index_subplots = reshape(1:n_limb, 2, n_limb/2).';
ax_Ncosphi = zeros(n_limb,1);
for i=1:n_limb
    ax_Ncosphi(i,1) = subplot(n_limb/2,2,index_subplots(i));
    hold on;
    i_limb_plot = limb_list_ordered(i);
    time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
        plot(time, GRF(:,i_limb_plot).*cos(phi(i_limb_plot,:))');
        ylabel('Z Load * cos phi [N]');
        ylim([-10 10]);
    xlim(xlims);
    xlabel('Time [s]');
    ax=gca();
    add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax.YLim,time,'b');
    title([limb_names_ordered{i} '  (LC ' num2str(i_limb_plot) ')']);
%     ax.FontSize = fontSizeTicks;
    grid on;
end
linkaxes(ax_Ncosphi,'x');


%% Ndot

f_Ndot=figure;
f_Ndot.Color = 'w';
index_subplots = reshape(1:n_limb, 2, n_limb/2).';
ax_Ndot = zeros(n_limb,1);
for i=1:n_limb
    ax_Ndot(i,1) = subplot(n_limb/2,2,index_subplots(i));
    hold on;
    i_limb_plot = limb_list_ordered(i);
    time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
    N_dot(:,i_limb_plot) = 0.1*diff(GRF_filtered(:,i_limb_plot))./diff(time);
    plot(time(2:end), N_dot(:,i_limb_plot));
%     ylabel('$$\dot{N}$$ [N/s]','Interpreter','latex');
    ylabel('N\_dot [10 N/s]');

    ylim([-10 10]);
    xlim(xlims);
    xlabel('Time [s]');
    ax=gca();
    add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax.YLim,time,'b');
    title([limb_names_ordered{i} '  (LC ' num2str(i_limb_plot) ')']);
%     ax.FontSize = fontSizeTicks;
    grid on;
end
linkaxes(ax_Ndot,'x');
