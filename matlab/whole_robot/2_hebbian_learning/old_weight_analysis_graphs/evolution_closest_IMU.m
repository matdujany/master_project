
AllChannels = 1; %channels of IMU to use (1 means AllChannels, 0 means only Z channel)
%we first sort the motors by their connection weights with the IMU
closest_IMU_fused_evolution = zeros(parms.n_twitches,parms.n_m);
closest_IMU_split_evolution = zeros(parms.n_twitches,parms.n_m*2);
for k=1:parms.n_twitches
    closest_IMU_fused_evolution(k,:)=find_closest_IMU(weights,k,0,AllChannels,parms);
    closest_IMU_split_evolution(k,:)=find_closest_IMU(weights,k,1,AllChannels,parms);
end
%then we compute the rank of each servo at each step
motors_rank_IMU_fused = zeros(parms.n_m,parms.n_twitches);
motors_rank_IMU_split = zeros(2*parms.n_m,parms.n_twitches);
for k=1:parms.n_twitches
    for m=1:parms.n_m
        motors_rank_IMU_fused(m,k) = find(closest_IMU_fused_evolution(k,:)==m);
    end
    for m=1:2*parms.n_m
        motors_rank_IMU_split(m,k) = find(closest_IMU_split_evolution(k,:)==m);
    end
end

colorlist = lines(parms.n_m);

%% figure fused
figure;
legend_list=cell(parms.n_m,1);
hold on;
for m=1:parms.n_m
    scatter(1:parms.n_twitches,motors_rank_IMU_fused(m,:),[],colorlist(m,:),'filled');
    legend_list{m}=strcat('M',num2str(m));
end
legend(legend_list);
xlabel('Twitch repetition');
xticks([1:parms.n_twitches]);
xlim([0.5 parms.n_twitches+0.5]);
ylabel('Rank (1 means stronger connection to IMU)');
yticks([1:parms.n_m]);
ylim([0.5 parms.n_m+0.5]);

%% figure split
figure;
legend_list=cell(2*parms.n_m,1);
hold on;
for m=1:2*parms.n_m
    if mod(m,2)==1
        legend_list{m}=strcat('M',num2str(ceil(m/2)),'-');
        markerstyle = 'v';
    else
        legend_list{m}=strcat('M',num2str(ceil(m/2)),'+');
        markerstyle = '^';
    end
    scatter(1:parms.n_twitches,motors_rank_IMU_split(m,:),[],colorlist(ceil(m/2),:),'filled','Marker',markerstyle);
end
legend(legend_list);
xlabel('Twitch repetition');
xticks([1:parms.n_twitches]);
xlim([0.5 parms.n_twitches+0.5]);
ylabel('Rank (1 means stronger connection to IMU)');
yticks([1:2*parms.n_m]);
ylim([0.5 2*parms.n_m+0.5]);
