function plot_weight_evolution_IMU(weights,parms)
%PLOT_WEIGHT_EVOLUTION_IMU Summary of this function goes here
%   Detailed explanation goes here

fontsize=14;
linewidth=1.3;

data_for_plot=zeros(parms.n_twitches,1);
colorlist = lines(parms.n_m);
legend_list = cell(parms.n_m*2,1);
if parms.n_useful_ch_IMU == 4
    figure;
    for i=1:parms.n_useful_ch_IMU
        subplot(2,2,i)
        plot_IMU(weights,parms,i,colorlist,['IMU channel ' num2str(i)],fontsize,linewidth,1);        
    end
else
    if parms.n_useful_ch_IMU ==6
        figure;
        for i=1:3
            subplot(2,2,i)
            legend_list = plot_IMU(weights,parms,i,colorlist,['IMU Accelerometer channel ' num2str(i)],fontsize,linewidth,0);
        end
        plot_legend_hack(parms,colorlist,legend_list,fontsize);
        figure;
        for i=1:3
            subplot(2,2,i)
            legend_list = plot_IMU(weights,parms,i+3,colorlist,['IMU Gyroscope channel ' num2str(i)],fontsize,linewidth,0);
        end
        plot_legend_hack(parms,colorlist,legend_list,fontsize);
    end
end

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

function legend_list = plot_IMU(weights,parms,channel,colorlist,titleString,fontsize,linewidth,flagShowLegend)
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
        data_for_plot(k) = weights{k}(3*parms.nr_arduino+channel,j);
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

