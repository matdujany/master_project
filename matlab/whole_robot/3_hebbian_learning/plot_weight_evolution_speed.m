function plot_weight_evolution_speed(weights_speed,parms)
%PLOT_WEIGHT_EVOLUTION_IMU Summary of this function goes here
%   Detailed explanation goes here

fontsize=14;
linewidth=1.3;

colorlist = lines(parms.n_m);
legend_list = cell(parms.n_m*2,1);
text_list_channels = {'X','Y','Z'};
figure;
for i=1:3
    subplot(2,2,i)
    legend_list = plot_speed(weights_speed,parms,i,colorlist,['Speed ' text_list_channels{i}],fontsize,linewidth,0);
end
plot_legend_hack(parms,colorlist,legend_list,fontsize);

end

function plot_legend_hack(parms,colorlist,legend_list,fontsize)
subplot(2,2,4)
%just a workaround/hack to plot the legend in a separate subplot
%matlab wants as many series as legend entries to show the legend
%so i plot series of (0,0)
hold on;
for j = 1:parms.n_m*2
    if mod(j,2) == 1
        linestyle = '--';
    else
        linestyle = '-';
    end
    plot(0,0,'LineStyle',linestyle,'Color',colorlist(ceil(j/2),:))
end
axis off
l=legend(legend_list{:});
l.FontSize = fontsize;
end

function legend_list = plot_speed(weights_speed,parms,channel,colorlist,titleString,fontsize,linewidth,flagShowLegend)
legend_list = cell(parms.n_m*2,1);
hold on
for j=1:parms.n_m*2
    if mod(j,2) == 1
        linestyle = '--';
        legend_list{j} = ['Motor ' num2str(ceil(j/2)) ', direction -'];
    else
        linestyle = '-';
        legend_list{j} = ['Motor ' num2str(ceil(j/2)) ', direction +'];
    end
    for k=1:parms.n_twitches
        data_for_plot(k) = weights_speed{k}(channel,j);
    end
    x_data = 0:parms.n_twitches;
    plot(x_data,[0;data_for_plot'],'LineStyle',linestyle,'Color',colorlist(ceil(j/2),:),'LineWidth',linewidth);
end
hold off
title(titleString,'FontSize',fontsize);
xlabel('Twitch iteration number','FontSize',fontsize);
xticks(x_data);
xlim([0 parms.n_twitches+0.5]);
if flagShowLegend
    l=legend(legend_list{:});
    l.FontSize = fontsize;
end
end

