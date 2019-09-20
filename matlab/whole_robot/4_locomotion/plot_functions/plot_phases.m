function [f_phase,ax_phase] = plot_phases(pos_phi_data,recordID,GRF,time_GRF)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;
xlims  = [0 60];

n_limb = size(pos_phi_data.limb_phi,1);

[limb_list_gait_diagram,limb_names_gait_diagram] = get_limb_list_names_gait_diagram(n_limb,recordID);
color_list = lines(n_limb);
if n_limb == 8
    color_list(n_limb,:) = [0.25, 0.25, 0.25];
end

bool_subplot = false;
if nargin >= 3
    bool_subplot = true;
end
f_phase=figure;
f_phase.Color = 'w';

if bool_subplot
    subplot(2,1,1);
end

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
% lgd.Location = 'northoutside';

if n_limb == 8
    lgd.NumColumns = 2;
end
grid on;
% yticks(pi[0:2]);
% yticklabels({'0','\pi','2\pi'});
xlim(xlims);
yticks(2*pi/3*[0:3]);
yticklabels({'0','2\pi/3','4\pi/3','2\pi'});
for i=1:2
    plot([time(1) time(end)],2*pi/3*[i i],'k--','LineWidth',1,'HandleVisibility','off');
end
ylim(2*pi*[0 1] + [0 0.5]);


if nargin == 3
    time_GRF = time;
end

if bool_subplot
    lgd.Location = 'east';
    subplot(2,1,2);
    plot(time_GRF,sum(GRF,2));
    ylabel('Total Load [N]');
    xlabel('Time [s]');
    ax_phase = [ax_phase; gca()];
    linkaxes(ax_phase,'x');
    grid on;
%     f_phase.Position = [1          41        1680         933];
%     ax_phase(2).Position(3) = ax_phase(1).Position(3);
end


set(zoom(f_phase),'Motion','horizontal');


end

