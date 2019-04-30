function plot_weight_evolution_LC_detailed(weights_detailed,parms,weights_robotis)
%weighs_detailed is nbLearningSamples,n_sensors,2*parms.n_m

fontsize=14;
linewidth=1.3;


n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);
colorlist = lines(parms.n_m);
legend_list = cell(parms.n_m*2,1);
for index_lc=1:parms.n_lc
    figure;
    for i=1:parms.n_ch_lc
        subplot(2,2,i)
        hold on
        for j=1:parms.n_m*2
            if mod(j,2) == 1
                linestyle = '--';
                legend_list{j} = ['Motor ' num2str(ceil(j/2)) ', direction -'];
            else
                linestyle = '-';
                legend_list{j} = ['Motor ' num2str(ceil(j/2)) ', direction +'];
            end
            plot(weights_detailed(:,i+3*(index_lc-1),j),'LineStyle',linestyle,'Color',colorlist(ceil(j/2),:),'LineWidth',linewidth);
            for k=1:parms.n_twitches
                scatter(k*n_frames_part1,weights_robotis{k}(i+3*(index_lc-1),j),'x','MarkerEdgeColor',colorlist(ceil(j/2),:));
            end
        end
        hold off
        title(['Loadcell ' num2str(index_lc) ', channel ' num2str(i)],'FontSize',fontsize);
        xlabel('Learning sample number','FontSize',fontsize);
        xlim([0.5 size(weights_detailed,1)+0.5]);
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
