%gait plot

clear; close all; clc;
addpath('../2_load_data_code');

recordID = 24;
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

n_limb = 8;
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion,n_limb);
n_limb = size(limbs,1);

% GRF = zeros(n_samples,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
end

%% plotting GRFs
xlims = [0 60]; %% in secs
figure;
limb_list_ordered = [5; 4; 3; 2; 6; 7; 8 ;1];
limb_names_ordered= {'L1','L2','L3','L4','R1','R2','R3','R4'};

index = reshape(1:n_limb, 2, n_limb/2).';
for i=1:n_limb
    subplot(n_limb/2,2,index(i));
    i_limb_plot = limb_list_ordered(i);
    time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
    plot(time, GRF(:,i_limb_plot));
    ylabel('Z Load [N]');
    ylim([-2 15]);
    xlim(xlims);
    xlabel('Time [s]');
    add_stance_patches_GRF(GRF(:,i_limb_plot),gca(),time,'b');
    title([limb_names_ordered{i} '  (LC ' num2str(i_limb_plot) ')']);
end

%% gait diagramm
xlims  = [0 60];
threshold_unloading = 0.5;
limb_list_gait_diagram = flip([6; 7; 8; 1; 5; 4; 3; 2]);
limb_names_gait_diagram = flip({'R1','R2','R3','R4','L1','L2','L3','L4'});
color_list = ['r','g','b','k'];
figure;
for i=1:n_limb
    i_limb_plot = limb_list_gait_diagram(i);
    [idx_start_stance,idx_stop_stance] = determine_start_stop_stance(GRF(:,i_limb_plot),threshold_unloading);
    time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
    for k=1:length(idx_start_stance)
        y_patch = i + 0.25*[-1 -1 1 1]; 
        x_patch = [idx_start_stance(k) idx_stop_stance(k) idx_stop_stance(k) idx_start_stance(k)];
        patch(time(x_patch),y_patch,color_list(mod(i,4)+1),'FaceAlpha',0.8,'EdgeColor','none','HandleVisibility','off');
    end
end
ax=gca();
ax.XGrid = 'on';
ax.XMinorGrid = 'on';
yticks([1:n_limb]);
yticklabels(limb_names_gait_diagram);
xlim(xlims);
xlabel('Time [s]');