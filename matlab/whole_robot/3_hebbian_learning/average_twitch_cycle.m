clear; 
close all; clc;

addpath('../data');

%% Load data
recordID = 1;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;

%%
[lpdata,data,idx_start,idx_end] = compute_avg_cycles(lpdata,data,parms);

%%
good_closest_LC = [3;3;4;4;1;1;2;2];

simulate = 0;
eta = 1;

splitDirections = 0;
allChannels = 1;
renorm = 0;
refine = 0;
n_iter = 5;

if simulate == 1
    parms.eta = eta;
    weights = compute_weights_wrapper(data,lpdata,parms);
else
    weights = read_weights_robotis(recordID,parms);
end
[closest_sensors,likelihoods] = find_closest_LC(weights,n_iter,splitDirections,allChannels,renorm,refine,parms);



%%
for i_lc=1:parms.nr_arduino
    figure;
    for channel=1:3
        subplot(2,2,channel);
        hold on;
        for i_motor=1:parms.n_m
            plot(lpdata.motor_position_avg(i_motor,:));
        end
        yyaxis right;
        %plot(data.float_value_dot_time_avg{1,i_lc}(:,channel),'--');
        plot(data.float_value_time_avg{1,i_lc}(:,channel),'--');
        title(['Channel ' num2str(channel)]);
    end
    subplot(2,2,4)
    %     plot(lpdata.m_dot_values_avg)
    %     hold on;
    %     for i=1:length(idx_start)
    %         plot([idx_start(i) idx_start(i)], [-0.5 0.5], 'b--');
    %         plot([idx_end(i) idx_end(i)], [-0.5 0.5], 'r--');
    %     end
    load_norm = (data.float_value_time_avg{1,i_lc}(:,1).^2+data.float_value_time_avg{1,i_lc}(:,2).^2+...
        data.float_value_time_avg{1,i_lc}(:,3).^2).^(1/2);
    hold on;
    for i_motor=1:parms.n_m
        plot(lpdata.motor_position_avg(i_motor,:));
    end
    yyaxis right;
    %plot(data.float_value_dot_time_avg{1,i_lc}(:,channel),'--');
    plot(load_norm,'--');
    title('Total load norm')
    sgtitle(['LC ' num2str(i_lc) ' has motors ' num2str(find(closest_sensors==i_lc)')]);
end
h = hinton_LC(weights{n_iter},parms);

