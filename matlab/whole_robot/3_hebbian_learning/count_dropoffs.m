function [totalcounts, min_dropoffs] = count_dropoffs(threshold_factor,data,parms,flagPlot)

n_frames_theo = get_theo_number_frames(parms);

totalcounts = zeros(parms.n_lc,2*parms.n_m,parms.n_twitches);
min_dropoffs = zeros(parms.n_lc,2*parms.n_m,parms.n_twitches);

for k_twitch = 1:parms.n_twitches
    index_start_twitch = 1+n_frames_theo.per_twitch*(k_twitch-1);
    for i_sensor = 1:parms.n_lc
        for i_motor = 1:2*parms.n_m
            index_start = index_start_twitch+n_frames_theo.per_action*(i_motor-1);
            index_end = index_start + n_frames_theo.per_action-1;
            data_loadz = data.float_value_time{1,i_sensor}(index_start:index_end,3);
%             data_loadz = data.s_lc_filtered(index_start:index_end,3*i_sensor);
            [totalcounts(i_sensor,i_motor,k_twitch), min_dropoffs(i_sensor,i_motor,k_twitch)] = ...
                count_dropoffs_sub(threshold_factor,data_loadz,n_frames_theo);
        end
    end
end


%%
if flagPlot
    plot_data_image(sum(totalcounts,3),parms,['Total counts of value below threshold (' num2str(threshold_factor) ' of static load)']);
    plot_data_image(-mean(min_dropoffs,3),parms,['Average (over ' num2str(parms.n_twitches) ' twitch cycles) of max load dropoff']);

end

end

function plot_data_image(data_image,parms,titleString)
fontsize=12;
f=figure;
colormap gray;
image(data_image,'CDataMapping','scaled');
lc_tick_label_list = cell(parms.n_lc,1);
for i=1:parms.n_lc
    lc_tick_label_list{i} = ['LC' num2str(i)];
end
yticks(1:parms.n_lc);
yticklabels(lc_tick_label_list);

motor_tick_label_list = cell(2*parms.n_m,1);
for i=1:2*parms.n_m
    if mod(i,2) == 1
        sign = '-';
    else
        sign = '+';
    end
    motor_tick_label_list{i} = ['M' num2str(ceil(i/2)) sign];
end
xticks(1:2*parms.n_m);
xticklabels(motor_tick_label_list);
c=colorbar;
c.FontSize = fontsize;
title(titleString,'FontSize',fontsize);
ax=gca();
ax.TickLength = [0 0];
ax.FontSize = fontsize;
axis image;
f.Color = 'w';
f.Position = [10 10 825 250];
for i_sensor = 1:parms.n_lc
    for i_motor = 1:2*parms.n_m
        value = data_image(i_sensor,i_motor);
        %             if ismember(value, maxk(data_image(i_sensor,:),3))
        color='k';
        text(i_motor,i_sensor,num2str(value,2),'FontSize',fontsize,'HorizontalAlignment','center','Color',color);
        %             end
    end
end
end

% function total_count = count_dropoffs_nb_samples(threshold_factor,data_loadz,n_frames_theo)
%
% mean_load_p0 = mean(data_loadz(1:n_frames_theo.part0));
% total_count = 0;
% threshold_load_value = threshold_factor*mean_load_p0;
% for i_frame = 1:n_frames_theo.part1
%     if data_loadz(n_frames_theo.part0+i_frame)<threshold_load_value
%         total_count = total_count + 1;
%     end
% end
% end