function [f_GRP,ax_grp] = plot_GRP(GRP,time_limbs,GRF,threshold_unloading,recordID)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

n_limb = size(GRP,2);

if size(time_limbs,2)==1
    time_limbs = repmat(time_limbs,1,n_limb);
end

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;

[limb_list_ordered,limb_names_ordered] = get_limb_list_names(n_limb,recordID);


f_GRP=figure;
f_GRP.Color = 'w';
index_subplots = reshape(1:n_limb, 2, n_limb/2).';
ax_grp = zeros(n_limb,1);
for i=1:n_limb
    ax_grp(i,1) = subplot(n_limb/2,2,index_subplots(i));
    hold on;
    i_limb_plot = limb_list_ordered(i);
    time = time_limbs(:,i_limb_plot);
%     time = (data.time(:,i_limb_plot)-data.time(1,i_limb_plot))/10^3;
    plot(time, GRP(:,i_limb_plot));
    ylabel('Y Load [N]');
    ylim([-5 5]);
    xlabel('Time [s]');
    ax=gca();
    add_stance_patches_GRF(GRF(:,i_limb_plot),threshold_unloading,ax.YLim,time,'b');
    title([limb_names_ordered{i} '  (LC ' num2str(i_limb_plot) ')']);
    ax.FontSize = fontSizeTicks;
    grid on;
end
linkaxes(ax_grp,'x');
f_GRP.Position = 10^3*[0.0018    0.4130    1.1752    0.3696];
end

