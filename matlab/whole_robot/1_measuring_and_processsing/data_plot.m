%% ROBOTIS - MATLAB ANALYSIS
%  data_plot.m
% 
%  DESCRIPTION: 
%  Construct plots of raw data and saves them or not depending on
%  'parms.print_figures' in set_parms.
% 
%  NOTES:
%  - Make sure to set the right parameters in the set_parameters file.

addpath('functions')
addpath('../data');

% warning('off')

%% Load data

recordID = 8;
load(strcat(get_record_name(recordID),'_p'));

%% Main

% Plot data % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% Indices of samples that are plotted in plotDataAnalytic
range_to_plot = 1:250;

% Run plot functions
for i_ard=1:parms.nr_arduino
    plotDataAnalytic(i_ard, data, 'float_value_time', range_to_plot)
    plotData(i_ard, data)
end
plotDataOverview(data, parms)

% Saving Figures  % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
figHandles = get(groot, 'Children');
if(parms.print_figures)
    for i = 1:length(figHandles)
       saveas(figHandles(i),strcat('figures/',selected_file(1:end-4),'_',num2str(i),'.png')) 
    end
end


%% Functions

function plotData(i_ard, data)

n_frames   = data.count_frames;
tmp        = data.float_value_time{i_ard};
time       = data.time(:,i_ard);

str_title  = strcat("Arduino ", num2str(i_ard)); 

f_tmp      = figure;
fig        = gcf;
hold on
plot(time/1000,tmp,'LineWidth', 2);
ax        = gca;
line([ax.XLim],[0 0],'Color','black','LineStyle','--')
title(str_title);
set(f_tmp,'units','normalized','outerposition',[0.3 0.5 0.7 0.5])
legend('Sensor 1','Sensor 2','Sensor 3')
xlabel('Time (s)');
ylabel('Load (kg)');

end



function plotDataAnalytic(i_ard, data, field, range)

n_frames   = data.count_frames;
% tick_array = [floor(1:data.count_frames/10:data.count_frames) data.count_frames];

% range = 1:250;

tmp = data.(field){i_ard}(range,:);
time = data.time(range,i_ard);

str_title = strcat("Arduino ", num2str(i_ard)); 

f_tmp = figure;
fig       = gcf;
hold on
% plot(time(1:end-1)/1000,diff(tmp(:,1)),'LineWidth', 2);
plot(time/1000,tmp,'LineWidth', 2);
plot(time/1000,tmp, 'k.');
ax        = gca;
line([ax.XLim],[0 0],'Color','black','LineStyle','--')
title(str_title);
% set(gca,'xtick',tick_array);
set(f_tmp,'units','normalized','outerposition',[0.3 0.5 0.7 0.5])
legend('Sensor 1','Sensor 2','Sensor 3')
xlabel('Time (s)');
ylabel('Load (kg)');

end



function plotDataOverview(data, parms)

n_frames   = data.count_frames;
tick_array = [floor(1:data.count_frames/10:data.count_frames) data.count_frames];

if mod(parms.nr_arduino,2) == 1
    sub_columns = floor(parms.nr_arduino / 2) + 2;
else
    sub_columns = (parms.nr_arduino / 2);
end

for i_ard = 1:parms.nr_arduino
    
    tmp = data.float_value_time{i_ard};
    
    str_title = strcat("Loadcell ", num2str(i_ard));
    
    time = data.time(:,i_ard);
    
    f_tmp     = figure(100);
    fig       = gcf;
    subplot(2,sub_columns,i_ard)
    hold on
    plot(time/1000,tmp,'LineWidth', 2);
    ax        = gca;
    line([ax.XLim],[0 0],'Color','black','LineStyle','--')
    title(str_title);
%     set(gca,'xtick',tick_array);
    legend('Sensor 1','Sensor 2','Sensor 3')
%     xlabel('# Frame number');
    xlabel('Time (s)');
    ylabel('Load (kg)');
    
end

% Plot IMU data
% i_sensory = 2: linear and gyro
idx_start_tmp = [1 4];
idx_end_tmp   = [3 4];

for i_sensory = 1:2
    tmp = data.float_value_time{parms.nr_arduino+1};
    %time = data.time(:,parms.nr_arduino+1);
    str_title = strcat("IMU");
    
    f_tmp     = figure(200);
    fig       = gcf;
    subplot(2,1,i_sensory)
    hold on
    plot(tmp(:,idx_start_tmp(i_sensory):idx_end_tmp(i_sensory)),'LineWidth', 2);
    %plot(time/1000,tmp(:,idx_start_tmp(i_sensory):idx_end_tmp(i_sensory)),'LineWidth', 2);
    ax        = gca;
    line([ax.XLim],[0 0],'Color','black','LineStyle','--')
    title(str_title);
    set(gca,'xtick',tick_array);
    if i_sensory == 1
        legend('xdd','ydd','zdd')
    elseif i_sensory == 2
        legend('yaw')
    end
    xlabel('# Frame number');
    %xlabel('Time (s)');
    if i_sensory == 1
        ylabel('Accelerometer (???)');
    elseif i_sensory == 2
        ylabel('Gyroscope (???)');
    end
end

set(f_tmp,'units','normalized','outerposition',[0.3 0.3 0.7 0.7])

end

