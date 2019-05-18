clear; 
close all; clc;

% addpath('../2_get_data_code');
% addpath('../plotting_functions');

%% Load data
recordID = 84;
[data, lpdata, parms] =  load_data_processed(recordID);
parms = add_parms(parms);

%%
[lpdata,data,idx_start,idx_end] = compute_avg_cycles(lpdata,data,parms);

%%
index_motor_plot = 1;
index_loadcell_plot = 1;

%% time signals
figure;
for channel=1:3
    subplot(2,2,channel);
    hold on;
    plot(lpdata.motor_position_avg(index_motor_plot,:),'b-');   
    plot(lpdata.motor_positionfiltered_avg(index_motor_plot,:),'b--');
    xlabel('Frame index');
    ylabel(['Motor ' num2str(index_motor_plot) ' Position']);
    yyaxis right;
    plot(data.float_value_time_avg{1,index_loadcell_plot}(:,channel),'r-');
    plot(data.s_lc_filtered_avg(:,channel+(index_loadcell_plot-1)*3),'r--');
    ylabel(['Loadcell channel ' num2str(channel) ' value [N]']);   
end

%% dot time signals
figure;
for channel=1:3
    subplot(2,2,channel);
    hold on;
    plot(lpdata.m_s_dot_pos_avg(index_motor_plot,:),'b-');   
    plot(lpdata.m_s_dot_posfiltered_avg(index_motor_plot,:),'b--');
    ylim([-0.5 0.5]);
    xlabel('Frame index');
    ylabel(['Motor ' num2str(index_motor_plot) ' Speed']);
    yyaxis right;
    plot(data.float_value_dot_time_avg{1,index_loadcell_plot}(:,channel),'r-');
    plot(data.s_dot_lc_filtered_avg(:,channel+(index_loadcell_plot-1)*3),'r--');
    ylim([-50 50]);
    ylabel(['Loadcell channel ' num2str(channel) ' value [N]']);   
end

%% dot time signals, filtered only
figure;
for channel=1:3
    subplot(2,2,channel);
    hold on;
    plot(lpdata.m_s_dot_posfiltered_avg(index_motor_plot,:),'b--');
    plot(lpdata.m_dot_learningfiltered_avg(:),'b-');
    ylim([-0.1 0.1]);
    xlabel('Frame index');
    ylabel(['Motor ' num2str(index_motor_plot) ' Speed']);
    yyaxis right;
    plot(data.s_dot_lc_filtered_avg(:,channel+(index_loadcell_plot-1)*3),'r--');
    ylim([-10 10]);
    ylabel(['Loadcell channel ' num2str(channel) ' value [N]']);   
end
sgtitle('Only filtered signals');

%% std evolution of m_dot_learning
f = figure;
plot(lpdata.m_dot_learning_std);
f = plot_patch_learning(f,idx_start,idx_end);

%% std evolution of all m_dots
figure;
plot(lpdata.m_s_dot_pos_std');
legend_list = cell(parms.n_m,1);
for i=1:length(legend_list)
    legend_list{i} = ['M' num2str(i)];
end
legend(legend_list);
plot_patch_learning(gcf(),idx_start,idx_end);

%% std evolution of all sensory signals
flagFiltered = 1;
figure;
legend_list = cell(3,1);
color_list = lines(3);
for i=1:parms.n_lc
    subplot(2,2,i);
    lcString = ['LC' num2str(i)];
    hold on;
    for channel=1:3
        if flagFiltered == 1
            dataplot = data.s_lc_filtered_std(:,channel+3*(parms.n_lc-1));
        else
            dataplot = data.float_value_time_std{1,i}(:,channel);
        end
        plot(dataplot,'Color',color_list(channel,:));
        legend_list{channel} = strcat(lcString,[', channel ' num2str(channel)]);
    end
    legend(legend_list);
    plot_patch_learning(gcf(),idx_start,idx_end);
    title(lcString);
    hold off;
end

%% std evolution of all dot sensory signals
flagFiltered = 0;
figure;
legend_list = cell(3,1);
color_list = lines(3);
for i=1:parms.n_lc
    subplot(2,2,i);
    lcString = ['LC' num2str(i)];
    hold on;
    for channel=1:3
        if flagFiltered == 1
            dataplot = data.s_dot_lc_filtered_std(:,channel+3*(parms.n_lc-1));
        else
            dataplot = data.float_value_dot_time_std{1,i}(:,channel);
        end
        plot(dataplot,'Color',color_list(channel,:));
        legend_list{channel} = strcat(lcString,[', channel ' num2str(channel)]);
    end
    legend(legend_list);
    plot_patch_learning(gcf(),idx_start,idx_end);
    title(lcString);
    hold off;
end

%%
[lc_dot_var,m_dot_var,m_dot_learning_var] = compute_metrics_variability(lpdata,data,parms);


