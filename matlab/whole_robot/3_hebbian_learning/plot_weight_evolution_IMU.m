function plot_weight_evolution_IMU(weights,parms)
%PLOT_WEIGHT_EVOLUTION_IMU Summary of this function goes here
%   Detailed explanation goes here

fontsize=14;
linewidth=1.3;

data_for_plot=zeros(parms.n_twitches,1);
colorlist = lines(parms.n_m);
legend_list = cell(parms.n_m*2,1);
figure;
for i=1:parms.n_useful_ch_IMU
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
        for k=1:parms.n_twitches
            data_for_plot(k) = weights{k}(end-i+1,j);
        end
        x_data = 0:parms.n_twitches;
        plot(x_data,[0;data_for_plot],'LineStyle',linestyle,'Color',colorlist(ceil(j/2),:),'LineWidth',linewidth);
    end
    hold off
    title(['IMU channel ' num2str(i)],'FontSize',fontsize);
    xlabel('Twitch iteration number','FontSize',fontsize);
    xticks(x_data);
    xlim([0 parms.n_twitches+0.5]);
    legend(legend_list{:});
    l=legend(legend_list{:});   
    l.FontSize = fontsize;
end

end

