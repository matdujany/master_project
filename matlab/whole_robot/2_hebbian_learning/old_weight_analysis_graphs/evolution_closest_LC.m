AllChannels=1;
renorm=0;
reaffine=0;
closest_LC_fused_evolution = zeros(parms.n_twitches,parms.n_m);
closest_LC_split_evolution = zeros(parms.n_twitches,parms.n_m*2);
for k=1:parms.n_twitches
    closest_LC_fused_evolution(k,:)=find_closest_LC(weights,k,0,AllChannels,renorm,reaffine,parms);
    closest_LC_split_evolution(k,:)=find_closest_LC(weights,k,1,AllChannels,renorm,reaffine,parms);
end

shifts =[-parms.n_m:parms.n_m-1]*0.05; %just to shift slightly the lines so that they dont overlap.
colorlist = lines(parms.n_m);

%% figure fused
figure;
legend_list=cell(parms.n_m,1);
hold on;
for m=1:parms.n_m
    plot(closest_LC_fused_evolution(:,m)+shifts(m),'color',colorlist(m,:));
   legend_list{m} = ['Motor ' num2str(m)];
end
hold off;
ylim([0.5 parms.n_lc+0.5]);
LC_values = [1:parms.n_lc]';
yticks(LC_values)
yticklabels(cellstr(num2str(LC_values, 'LC%-d')))
xlabel('Twitch repetition');
xticks([1:parms.n_twitches]);
xlim([0.5 parms.n_twitches+0.5]);
legend(legend_list);
title('Closest LC for each motor (higher connection weights)');

%% figure split
figure;
legend_list=cell(parms.n_m*2,1);
hold on;
for m=1:parms.n_m*2
    if mod(m,2) == 1
        linestyle = '--';
        legend_list{m} = ['Motor ' num2str(ceil(m/2)) ', direction -'];
    else
        linestyle = '-';
        legend_list{m} = ['Motor ' num2str(ceil(m/2)) ', direction +'];
    end
    plot(closest_LC_split_evolution(:,m)+shifts(m),'color',colorlist(ceil(m/2),:),'LineStyle',linestyle);
end
hold off;
ylim([0.5 parms.n_lc+0.5]);
LC_values = [1:parms.n_lc]';
yticks(LC_values)
yticklabels(cellstr(num2str(LC_values, 'LC%-d')))
xlabel('Twitch repetition');
xticks([1:parms.n_twitches]);
xlim([0.5 parms.n_twitches+0.5]);
legend(legend_list);
title('Closest LC for each motor (higher connection weights)');


%% figure fused non hips hardcoded
figure;
legend_list=cell(parms.n_m/2,1);
counts=1;
hold on;
ids = [2,3,13,14,15,16,17,18];
for m=[2:2:8]
   plot(closest_LC_fused_evolution(:,m)+shifts(m));
   legend_list{counts} = ['Motor ' num2str(ids(m))];
   counts = counts + 1;
end
hold off;
ylim([0.5 parms.n_lc+0.5]);
LC_values = [1:parms.n_lc]';
yticks(LC_values)
yticklabels(cellstr(num2str(LC_values, 'LC%-d')))
xlabel('Twitch repetition');
xticks([1:parms.n_twitches]);
xlim([0.5 parms.n_twitches+0.5]);
legend(legend_list);
title('Closest LC for each motor (higher connection weights)');