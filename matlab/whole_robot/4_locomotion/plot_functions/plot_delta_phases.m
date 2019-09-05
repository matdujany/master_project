function [f_delta_phases,ax_delta_phases] = plot_delta_phases(pos_phi_data,delta_phases,recordID)

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;
xlims  = [0 60];
n_limb = size(pos_phi_data.limb_phi,1);
[limb_list_ordered,limb_names_ordered] = get_limb_list_names(n_limb,recordID);
[limb_list_gait_diagram,limb_names_gait_diagram] = get_limb_list_names_gait_diagram(n_limb,recordID);

color_list = lines(n_limb);
if n_limb == 8
    color_list(n_limb,:) = [0.25, 0.25, 0.25];
end

f_delta_phases = figure;
f_delta_phases.Color = 'w';
index_subplots = reshape(1:n_limb, 2, n_limb/2).';
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
%             delta_phase = unwrap(mod(pos_phi_data.limb_phi(j_limb,:)-pos_phi_data.limb_phi(index_limb,:),2*pi));
            plot(time,squeeze(delta_phases(j_limb,index_limb,:)),'LineWidth',1.5,'Color',color_list(j,:));                       
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

end