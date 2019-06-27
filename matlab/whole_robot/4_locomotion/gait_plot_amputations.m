%gait plot

clear; close all; clc;
addpath('../2_load_data_code');
addpath('../../export_fig');

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

%%
recordID = 124;
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
parms_locomotion = add_parms_change_recordings(parms_locomotion,recordID);

n_limb = 6;
[limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion,n_limb,recordID);
n_limb = size(limbs,1);

% GRF = zeros(n_samples,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
end

%filtered version:
size_mv_average = 6;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
GRF_filtered = zeros(size(GRF));
for i=1:n_limb
    GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i));
end

GRF = GRF_filtered;

%%
threshold_unloading = 0.2; %Fukuhuara, figure 6, stance if more than 20% of maximal value
[value_unloading,max_value_GRF_limb] = determine_value_unloading(GRF,threshold_unloading);

%% plotting GRFs
switch n_limb
    case 4
        limb_list_ordered = [3; 4; 2 ;1];
        limb_names_ordered= {'L1','L2','R1','R2'};
        if ismember(recordID,[70:104 115:120])
            limb_list_ordered = [2; 4; 1 ;3];
            limb_names_ordered= {'F','B','R','L'};
        end
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

xlims = [110 120]; %% in secs
f_GRF=figure;
f_GRF.Color = 'w';
index_subplots = reshape(1:n_limb, 2, n_limb/2).';
ax_grf = zeros(n_limb,1);
for i=1:n_limb
    ax_grf(i,1) = subplot(n_limb/2,2,index_subplots(i));
    hold on;
    i_limb_plot = limb_list_ordered(i);
    time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
    plot(time, GRF(:,i_limb_plot));
    plot([time(1) time(end)],[value_unloading(i_limb_plot) value_unloading(i_limb_plot)],'k--');
    ylabel('Z Load [N]');
    ylim([-2 13]);
    xlim(xlims);
    xlabel('Time [s]');
    ax=gca();
    add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax.YLim,time,'b');
    title([limb_names_ordered{i} '  (LC ' num2str(i_limb_plot) ')']);
    ax.FontSize = fontSizeTicks;
    grid on;
end
linkaxes(ax_grf,'x');
f_GRF.Position = 10^3*[0.0018    0.4130    1.1752    0.3696];
% f_GRF.Position = 10^3*[0.0018    0.2590    1.1752    0.5236];
% f_GRF.Position = 10^3*[0.0018    0.0640    1.1752    0.7186];

%% gait diagramm
xlims  = [0 60];
switch n_limb
    case 4
        limb_list_gait_diagram = [2; 1; 3 ;4];
        limb_names_gait_diagram= {'R1','R2','L1','L2'};
        if ismember(recordID,[70:104 115:120])
            limb_list_gait_diagram = [2; 1; 3 ;4];
            limb_names_gait_diagram= {'F','R','L','B'};
        end
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
if n_limb == 8
    color_list(n_limb,:) = [0.25, 0.25, 0.25];
end

f_gait=figure;
f_gait.Color = 'w';
for i=1:n_limb
    i_limb_plot = limb_list_gait_diagram(i);
    [idx_start_stance,idx_stop_stance] = determine_start_stop_stance(GRF(:,i_limb_plot),threshold_unloading);
    time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
    for k=1:length(idx_start_stance)
        y_patch = 1 + n_limb - i + 0.25*[-1 -1 1 1];
        x_patch = [idx_start_stance(k) idx_stop_stance(k) idx_stop_stance(k) idx_start_stance(k)];
%         color_patch = color_list(mod(i,4)+1);
        color_patch = color_list(i,:);
        patch(time(x_patch),y_patch,color_patch,'FaceAlpha',1,'EdgeColor','none','HandleVisibility','off');
    end
end
ax_gait=gca();
ax_gait.XGrid = 'on';
ax_gait.XMinorGrid = 'on';
ax_gait.FontSize = fontSizeTicks;
yrule = ax_gait.YAxis;
yrule.FontSize = fontSizeTicks+2;

yticks([1:n_limb]);
yticklabels(flip(limb_names_gait_diagram));
ylim([1 n_limb] + 0.6*[-1 1])
xlim(xlims);
xlabel('Time [s]');
f_gait.Position = [7.4000 44.2000 1184 222.8000];
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
f_phase.Color = 'w';
% title('Limb Phases');
for i_limb = 1:n_limb
    hold on;
    time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
    plot(time,mod(pos_phi_data.limb_phi(limb_list_gait_diagram(i_limb),:),2*pi),'LineWidth',1.5,'Color',color_list(i_limb,:));
    ylabel('Phase [rad]');
    xlabel('Time [s]');
    legend_list{i_limb} = [limb_names_gait_diagram{i_limb} ' - Limb ' num2str(limb_list_gait_diagram(i_limb))];
    if n_limb == 8
        legend_list{i_limb} = limb_names_gait_diagram{i_limb};
    end
end
ax_phase=gca();
ax_phase.FontSize = fontSizeTicks;
lgd=legend(legend_list);
lgd.FontSize = fontSize;
lgd.Location = 'eastoutside';
if n_limb == 8
    lgd.NumColumns = 2;
end
grid on;
f_phase.Position = [6 356 1184 174];
set(zoom(f_phase),'Motion','horizontal');
yticks(pi*[0:2]);
yticklabels({'0','\pi','2\pi'});
ylim(2*pi*[0 1] + [0 0.5]);

%% total load;
f_total_load = figure;
time = (data.time(:,1)-data.time(1,1))/10^3;
plot(time,sum(GRF_filtered,2));
f_total_load.Position = [57.4         94.2         1184        302.4];
ax_total_load =gca();
ax_total_load.FontSize = fontSizeTicks;

set(zoom(f_total_load),'Motion','horizontal');

%% delta phases


f_delta_phases = figure;
f_delta_phases.Color = 'w';
ax_delta_phases = zeros(n_limb,1);
for i=1:n_limb
    ax_delta_phases(i,1) = subplot(n_limb/2,2,index_subplots(i));
    time = pos_phi_data.phi_update_timestamp(1,:)/10^3;
    hold on;
    legend_list = cell(n_limb-1,1);
    count = 1;
    index_limb = limb_list_ordered(i);
    for j=1:n_limb
        j_limb = limb_list_gait_diagram(j);
        if j_limb~=index_limb
            plot(time,unwrap(mod(pos_phi_data.limb_phi(j_limb,:)-pos_phi_data.limb_phi(index_limb,:),2*pi)),'LineWidth',1.5,'Color',color_list(j,:));
            legend_list{count,1} = [limb_names_gait_diagram{j} ' (Limb ' num2str(j_limb) ')'];
            if n_limb == 8
                legend_list{count,1} = limb_names_gait_diagram{j};
            end
            count = count + 1;
        end
    end
    
    ylabel('Delta Phase [rad]');
    xlabel('Time [s]');
    title(['Phase reference: ' limb_names_ordered{i} ' (Limb ' num2str(index_limb) ')']);
    lgd=legend(legend_list);
    lgd.FontSize = fontSize;
    lgd.Location = 'eastoutside';
    if n_limb == 8
        lgd.NumColumns = 2;
    end
    ax = gca();
    ax.FontSize = fontSizeTicks;
    grid on;
    y_min_delta_phase_range = -10;
    y_max_delta_phase_range = 10;
    
    yticks(pi*[y_min_delta_phase_range:y_max_delta_phase_range]);
    pi_label_lists = make_pi_label_lists(y_min_delta_phase_range,y_max_delta_phase_range);
    yticklabels(pi_label_lists);
    ylim(pi*2*[-1 1] + 0.5*[-1 1]);
    
%     yticks(pi/2*[y_min_delta_phase_range:y_max_delta_phase_range]);
%     pi_label_lists = {'-3/2\pi','-\pi','-1/2\pi','0','1/2\pi','\pi','3/2\pi'};
%     yticklabels(pi_label_lists);   
%     ylim(3*pi/2*[-1 1] + 0.5*[-1 1]);
    
    yrule = ax.YAxis;
    yrule.FontSize = fontSizeTicks+2;
end
f_delta_phases.Position =[5         232        1912         746];
if n_limb == 8
    f_delta_phases.Position =[1 41 1920 963];
end
set(zoom(f_delta_phases),'Motion','horizontal');

linkaxes([ax_grf;ax_gait;ax_phase;ax_total_load; ax_delta_phases],'x');
%%
xlim([190 205]);

%%
if false
    export_fig(['figures_report_locomotion/delta_phases_' num2str(recordID) '.pdf'],f_delta_phases);
end

if false
    export_fig(['figures_report_locomotion/gait_diagram_' num2str(recordID) '.pdf'],f_gait);
end

if false
    export_fig(['figures_report_locomotion/phases_' num2str(recordID) '.pdf'],f_phase);
end

if false
%     export_fig(['figures_report_locomotion/GRF_' num2str(recordID) '.pdf'],f_GRF);
    f_GRF.PaperOrientation = 'landscape';
    print(f_GRF, '-dpdf', '-bestfit', ['figures_report_locomotion\GRF_' num2str(recordID) '.pdf']); 
end
