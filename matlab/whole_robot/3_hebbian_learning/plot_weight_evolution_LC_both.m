function plot_weight_evolution_LC_both(weights,parms,flagDetailed,weights_detailed,opt_parms)

fontsize=14;
linewidth=1.3;

if nargin == 4
    opt_parms.motor_list = 1:2*parms.n_m;
    opt_parms.lc_list = 1:parms.n_lc;
end

n_frames_part1 = floor(parms.duration_part1/parms.time_interval_twitch);

% colorlist = lines(ceil(length(opt_parms.motor_list)/2));
colorlist = lines(ceil(length(opt_parms.motor_list)/2));

legend_list = cell(length(opt_parms.motor_list),1);
linestyle_list = cell(length(opt_parms.motor_list),1);

for i_lc=1:length(opt_parms.lc_list)
    index_lc = opt_parms.lc_list(i_lc);
    figure;
    for i=1:parms.n_ch_lc
        subplot(2,2,i)
        hold on
        for j=1:length(opt_parms.motor_list)
            index_motor = opt_parms.motor_list(j);
            if mod(index_motor,2) == 1
                linestyle = '--';
                legend_list{j} = ['Motor ' num2str(ceil(index_motor/2)) ', direction -'];
            else
                linestyle = '-';
                legend_list{j} = ['Motor ' num2str(ceil(index_motor/2)) ', direction +'];
            end
            linestyle_list{j} = linestyle;
            if flagDetailed
                x_data =  size(weights_detailed,1);
                plot(weights_detailed(:,i+3*(index_lc-1),index_motor),'LineStyle',linestyle,'Color',colorlist(ceil(j/2),:),'LineWidth',linewidth);
                for k=1:parms.n_twitches
                    scatter(k*n_frames_part1,weights{k}(i+3*(index_lc-1),index_motor),'x','MarkerEdgeColor',colorlist(ceil(j/2),:));
                end
            else
                data_for_plot=zeros(parms.n_twitches,1);
                for k=1:parms.n_twitches
                    data_for_plot(k) = weights{k}(i+(index_lc-1)*parms.n_ch_lc,index_motor);
                end
                x_data = 0:parms.n_twitches;
                plot(x_data,[0;data_for_plot],'LineStyle',linestyle,'Color',colorlist(ceil(j/2),:),'LineWidth',linewidth);
            end
        end
        hold off
        title(['Loadcell ' num2str(index_lc) ', channel ' num2str(i)],'FontSize',fontsize);
        if flagDetailed
            xlabel('Learning sample number','FontSize',fontsize);
        else
            xlabel('Twitch iteration number','FontSize',fontsize);
        end
        xticks(x_data);
        xlim([0 max(x_data)+0.5]);
    end
    subplot(2,2,4)
    %just a workaround/hack to plot the legend in a separate subplot
    %matlab wants as many series as legend entries to show the legend
    %so i plot series of (0,0)
    hold on;
    for j = 1:length(opt_parms.motor_list)
        plot(0,0,'LineStyle',linestyle_list{j},'Color',colorlist(ceil(j/2),:))
    end
    axis off
    l=legend(legend_list{:});   
    l.FontSize = fontsize;
end
end
