function [f_gait,ax_gait] = plot_gait_diagram(GRF,time_limbs,threshold_unloading,recordID)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;
xlims  = [0 60];

n_limb = size(GRF,2);
[limb_list_gait_diagram,limb_names_gait_diagram] = get_limb_list_names_gait_diagram(n_limb,recordID);

if size(time_limbs,2)==1
    time_limbs = repmat(time_limbs,1,n_limb);
end

color_list = lines(n_limb);
if n_limb == 8
    color_list(n_limb,:) = [0.25, 0.25, 0.25];
end

f_gait=figure;
f_gait.Color = 'w';
for i=1:n_limb
    i_limb_plot = limb_list_gait_diagram(i);
    [idx_start_stance,idx_stop_stance] = determine_start_stop_stance(GRF(:,i_limb_plot),threshold_unloading);
    time = time_limbs(:,i_limb_plot);
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

end

