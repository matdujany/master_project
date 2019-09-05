function [f_GRF,ax_grf] = plot_GRF(GRF,data,threshold_unloading,n_limb,recordID)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

[limb_list_ordered,limb_names_ordered] = get_limb_list_names(n_limb,recordID);
[value_unloading,~] = determine_value_unloading(GRF,threshold_unloading);

f_GRF=figure;
f_GRF.Color = 'w';
index_subplots = reshape(1:n_limb, 2, n_limb/2).';
ax_grf = zeros(n_limb,1);
for i=1:n_limb
%     ax_grf(i,1) = subplot(n_limb/2,2,index_subplots(i));
    subplot(n_limb/2,2,index_subplots(i));
    hold on;
    i_limb_plot = limb_list_ordered(i);
    time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
    plot([time(1) time(end)],[value_unloading(i_limb_plot) value_unloading(i_limb_plot)],'k--');
    plot(time, GRF(:,i_limb_plot));
    ylabel('Z Load [N]');
    ylim([-2 13]);
    xlabel('Time [s]');
    ax=gca();
    add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax.YLim,time,'b');
    title([limb_names_ordered{i} '  (LC ' num2str(i_limb_plot) ')']);
    ax.FontSize = fontSizeTicks;
    ax_grf(i,1) = ax;
    grid on;
end
linkaxes(ax_grf,'x');
f_GRF.Position = 10^3*[0.0018    0.4130    1.1752    0.3696];
end

