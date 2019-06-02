%gait plot

clear; close all; clc;
addpath('../2_load_data_code');

recordID = 50;
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
parms_locomotion = add_parms_change_recordings(parms_locomotion,recordID);

n_limb = 8;
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion,n_limb,recordID);
n_limb = size(limbs,1);

% GRF = zeros(n_samples,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
end

%filtered version:
size_mv_average = 5;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
GRF_filtered = zeros(size(GRF));
for i=1:n_limb
    GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i));
end

GRF = GRF_filtered;

%%
threshold_unloading = 0.2; %Fukuhuara, figure 6, stance if more than 20% of maximal value
%% plotting GRFs
switch n_limb
    case 4
        limb_list_ordered = [3; 4; 2 ;1];
        limb_names_ordered= {'L1','L2','R1','R2'};      
    case 6
        limb_list_ordered = [4; 5; 6; 3; 2; 1];
        limb_names_ordered= {'L1','L2','L3','R1','R2','R3'};           
    case 8
        limb_list_ordered = [5; 4; 3; 2; 6; 7; 8 ;1];
        limb_names_ordered= {'L1','L2','L3','L4','R1','R2','R3','R4'};
        if recordID >= 50
            limb_list_ordered = [5; 6; 7; 8; 4; 3; 2; 1];
        end
end

xlims = [0 60]; %% in secs
f=figure;
f.Color = 'w';
index = reshape(1:n_limb, 2, n_limb/2).';
ax_grf = zeros(n_limb,1);
for i=1:n_limb
    ax_grf(i,1) = subplot(n_limb/2,2,index(i));
    i_limb_plot = limb_list_ordered(i);
    time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
    plot(time, GRF(:,i_limb_plot));
    ylabel('Z Load [N]');
    ylim([-2 15]);
    xlim(xlims);
    xlabel('Time [s]');
    ax=gca();
    add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax.YLim,time,'b');
    title([limb_names_ordered{i} '  (LC ' num2str(i_limb_plot) ')']);
end
linkaxes(ax_grf,'x');
f.Position = [1.8        362.6       1175.2          420];

%% gait diagramm
xlims  = [0 60];
switch n_limb
    case 4
        limb_list_gait_diagram = [2; 1; 3 ;4];
        limb_names_gait_diagram= {'R1','R2','L1','L2'};      
    case 6
        limb_list_gait_diagram = [3; 2; 1; 4; 5; 6];
        limb_names_gait_diagram= {'R1','R2','R3','L1','L2','L3'};   
    case 8
        limb_list_gait_diagram = [6; 7; 8; 1; 5; 4; 3; 2];
        limb_names_gait_diagram = {'R1','R2','R3','R4','L1','L2','L3','L4'};
        if recordID >= 50
            limb_list_gait_diagram = [4; 3; 2; 1; 5; 6; 7; 8];
        end
end

% color_list = ['r','g','b','k'];
color_list = lines(n_limb);
f_gait=figure;
f_gait.Color = 'w';
for i=1:n_limb
    i_limb_plot = limb_list_gait_diagram(i);
    [idx_start_stance,idx_stop_stance] = determine_start_stop_stance(GRF(:,i_limb_plot),threshold_unloading);
    time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
    for k=1:length(idx_start_stance)
        y_patch = 1 + n_limb - i + 0.25*[-1 -1 1 1]; 
        x_patch = [idx_start_stance(k) idx_stop_stance(k) idx_stop_stance(k) idx_start_stance(k)];
        color_patch = color_list(mod(i,4)+1);
        color_patch = color_list(i,:);
        patch(time(x_patch),y_patch,color_patch,'FaceAlpha',0.8,'EdgeColor','none','HandleVisibility','off');
    end
end
ax_gait=gca();
ax_gait.XGrid = 'on';
ax_gait.XMinorGrid = 'on';
yticks([1:n_limb]);
yticklabels(flip(limb_names_gait_diagram));
xlim(xlims);
xlabel('Time [s]');
f_gait.Position = [7.4         44.2         1184        302.4];
set(zoom(f_gait),'Motion','horizontal')

%% phases
% switch n_limb
%     case 4
%         limb_list_phase = [2; 1; 3 ;4];
%         limb_names_phase= {'R1','R2','L1','L2'};      
%     case 6
%         limb_list_phase = [3; 2; 1; 4; 5; 6];
%         limb_names_phase= {'R1','R2','R3','L1','L2','L3'}   ;
%     case 8
%         limb_list_phase = [6; 7; 8; 1; 5; 4; 3; 2];
%         limb_names_phase = {'R1','R2','R3','R4','L1','L2','L3','L4'};
%         if recordID >= 50
%             limb_list_phase = [4; 3; 2; 1; 5; 6; 7; 8];
%         end
% end

f_phase=figure;
title('Phases computed by robotis');
for i_limb = 1:n_limb
    hold on;
    time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
    plot(time,mod(pos_phi_data.limb_phi(limb_list_gait_diagram(i_limb),:),2*pi),'LineWidth',1.5,'Color',color_list(i_limb,:));
    ylabel('Phase [rad]');
    xlabel('Time [s]');
    legend_list{i_limb} = [limb_names_gait_diagram{i_limb} ' - Limb ' num2str(limb_list_gait_diagram(i_limb))];
end
ax_phase=gca();
lgd=legend(legend_list);
f_phase.Position = [57.4         94.2         1184        302.4];
set(zoom(f_phase),'Motion','horizontal');

%% total load;
f_total_load = figure;
time = (data.time(:,1)-data.time(1,1))/10^3;
plot(time,sum(GRF_filtered,2));
f_total_load.Position = [57.4         94.2         1184        302.4];
ax_total_load =gca();

set(zoom(f_total_load),'Motion','horizontal');

%%
linkaxes([ax_grf;ax_gait;ax_phase;ax_total_load],'x');

%%
xlim([0 60]);


%%
if recordID == 26
    t_start_0_15 = 84.4;
    t_stop_0_15 = 112.3;
    duty_factor_0_15 = compute_duty_factor(GRF,data,t_start_0_15,t_stop_0_15,threshold_unloading);
    
    t_start_0_5 = 160.3;
    t_stop_0_5 = 174.6;
    duty_factor_0_5 = compute_duty_factor(GRF,data,t_start_0_5,t_stop_0_5,threshold_unloading);
end