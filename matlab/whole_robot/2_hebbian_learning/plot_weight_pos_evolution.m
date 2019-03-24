function plot_weight_pos_evolution(weights_pos,parms,hidediag)

fontsize=14;
linewidth=1.3;

data_for_plot=zeros(parms.n_twitches,1);
colorlist = lines(parms.n_m);
legend_list = cell(parms.n_m*2,1);
counts = 1;
for index_figure=1:ceil(parms.n_m/3)
    figure;
    for i=1:3
        if counts <= parms.n_m
        subplot(2,2,i)
        hold on
        for j=1:parms.n_m*2
            if hidediag == 1
                if j==1+2*(counts-1) || j==2*counts
                    continue;
                end
            end
            if mod(j,2) == 1
                linestyle = '--';
                legend_list{j} = ['Motor ' num2str(ceil(j/2)) ', direction -'];
            else
                linestyle = '-';
                legend_list{j} = ['Motor ' num2str(ceil(j/2)) ', direction +'];
            end
            for k=1:parms.n_twitches
                data_for_plot(k) = weights_pos{k}(counts,j);
            end
            plot(data_for_plot,'LineStyle',linestyle,'Color',colorlist(ceil(j/2),:),'LineWidth',linewidth);
        end
        hold off
        title(['Motor Pos ' num2str(counts)],'FontSize',fontsize);
        xlabel('Twitch iteration number','FontSize',fontsize);
        xticks([1:parms.n_twitches]);
        xlim([0.5 parms.n_twitches+0.5]);
        counts = counts + 1;
        end
    end
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

end