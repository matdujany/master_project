function f=plot_weight_evolution_speed(weights_speed,parms,opt_parms)
%PLOT_WEIGHT_EVOLUTION_IMU Summary of this function goes here
%   Detailed explanation goes here

fontsize=14;
linewidth=1.3;

if nargin == 2
    opt_parms.motor_list = 1:2*parms.n_m;
end

colorlist = lines(parms.n_m);
legend_list = cell(parms.n_m*2,1);
text_list_channels = {'X','Y','Z'};
f=figure;
for i=1:3
    subplot(1,4,i)
    legend_list = plot_speed(weights_speed,parms,i,colorlist,['Speed ' text_list_channels{i}],fontsize,linewidth,0,opt_parms);
end
plot_legend_hack(parms,colorlist,legend_list,fontsize,opt_parms);
f.Color = 'w';
end

function plot_legend_hack(parms,colorlist,legend_list,fontsize,opt_parms)
subplot(1,4,4)
%just a workaround/hack to plot the legend in a separate subplot
%matlab wants as many series as legend entries to show the legend
%so i plot series of (0,0)
hold on;
for j_sub=1:length(opt_parms.motor_list)
    j = opt_parms.motor_list(j_sub);
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
l.Position = [0.759436060557064,0.07459388574413,0.138467575728145,0.872946029537721];
end


function legend_list = plot_speed(weights_speed,parms,channel,colorlist,titleString,fontsize,linewidth,flagShowLegend,opt_parms)
legend_list = cell(length(opt_parms.motor_list),1);
hold on
for j_sub=1:length(opt_parms.motor_list)
    j = opt_parms.motor_list(j_sub);
    if mod(j,2) == 1
        linestyle = '--';
        legend_list{j_sub} = ['Motor ' num2str(ceil(j/2)) ', direction -'];
    else
        linestyle = '-';
        legend_list{j_sub} = ['Motor ' num2str(ceil(j/2)) ', direction +'];
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
ylabel('Weight value','FontSize',fontsize);

xticks(x_data);
xlim([0 parms.n_twitches+0.5]);
if flagShowLegend
    l=legend(legend_list{:});
    l.FontSize = fontsize;
end
ax=gca();
ax.FontSize = fontsize-2;
grid on;
if isfield(opt_parms,'ylims')
    ylim(opt_parms.ylims);
end
end

