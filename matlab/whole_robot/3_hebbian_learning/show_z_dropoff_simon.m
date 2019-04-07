clear; 
close all; clc;

addpath('../2_load_data_code');

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.4;

%% Load data
recordID = 17;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_robotis = read_weights_robotis(recordID,parms);

hinton_LC(weights_robotis{parms.n_twitches},parms);

idx_twitch = 2;
idx_motor = 7;
%idx_dir = 1; %-1 for - dir, +1 for + dir
good_closest_LC = [3;3;4;4;1;1;2;2];
idx_lc = good_closest_LC(idx_motor);

n_frames_theo = get_theo_number_frames(parms);
index_start = 1+n_frames_theo.per_twitch*(idx_twitch-1) + n_frames_theo.per_action*(idx_motor-1)*parms.n_dir;
index_end = n_frames_theo.per_twitch*(idx_twitch-1)  + n_frames_theo.per_action*idx_motor*parms.n_dir;

%% time signals
time_plot =(0:index_end-index_start)*parms.time_interval_twitch/1000;
motor_pos_plot = pos2deg(lpdata.motor_position(idx_motor,index_start:index_end));

idx_channel = 3;
for i=1:4
    data_lc{i} = data.float_value_time{1,i}(index_start:index_end,idx_channel);
end

legend_list_time = {['Motor ' num2str(idx_motor)],'Loadcell 1 Z','Loadcell 2 Z','Loadcell 3 Z','Loadcell 4 Z'};
%legend_list_time = {['Motor ' num2str(idx_motor)],'LC 1 Z','LC 2 Z','LC 3 Z','LC 4 Z'};

%% patches learning
index_start_learning1 = n_frames_theo.part0+1;
index_stop_learning1 = n_frames_theo.part0 + n_frames_theo.part1;
index_start_learning2 = n_frames_theo.per_action+n_frames_theo.part0+1;
index_stop_learning2 = n_frames_theo.per_action+ n_frames_theo.part0 + n_frames_theo.part1;
n_frames = index_end-index_start+1;

ymin = -20;
ymax = 20;
x_patch_learning1 = [index_start_learning1 index_stop_learning1 index_stop_learning1 index_start_learning1]*parms.time_interval_twitch;
y_patch_learning_pos = [ymin ymin ymax ymax];
x_patch_learning2 = [index_start_learning2 index_stop_learning2 index_stop_learning2 index_start_learning2]*parms.time_interval_twitch;

x_patch_dropoff = [825 1050 1050 825]/1000;
y_patch_dropoff = [-1 -1 4 4];

%% figure

manual_grid_values = [0 4]; 

color_list=lines(5);
f=figure;
%time signals part
hold on;
plot(time_plot,motor_pos_plot,'Color',color_list(1,:),'LineStyle', '-','LineWidth',lineWidth);
xlabel('Time [s]','FontSize',fontSize);
ylabel('Position [deg]','FontSize',fontSize);
yyaxis right;
for i=1:4
    linestyle = '--';
    if i== good_closest_LC(idx_motor)
        linestyle = '-';
    end
    plot(time_plot,data_lc{i},'Color',color_list(1+i,:),'LineStyle', linestyle,'LineWidth',lineWidth);
end
for i=1:length(manual_grid_values)
    plot([time_plot(1)-10 time_plot(end)+10],[manual_grid_values(i) manual_grid_values(i)],'LineStyle', '-','Color',[1,0,0,0.5]);
end
xlim([time_plot(1) time_plot(end)]);
patch(x_patch_dropoff,y_patch_dropoff,'red','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
ylabel('Load channel Z [N]','Color','r','FontSize',fontSize);
ylim([-3 15]);
lgd = legend(legend_list_time);
lgd.FontSize = fontSize-2;
lgd.Location = 'northwest';
lgd.Position = [0.4317,0.7244,0.278,0.2267];
lgd.NumColumns = 2;
ax = gca;
ax.FontSize = fontSizeTicks;
ax.YAxis(2).Color = 'r'; 
ax.YGrid = 'off'; 
ax.XGrid = 'on'; 

f.Color = 'w';

addpath('../../export_fig');

%%
set(f,'PaperPositionMode','auto');         
set(f,'PaperOrientation','landscape');
set(f,'Position',[10 10 1000 300]);

%%
%print(f, '-dpdf', 'figures_simon/z_dropoff.pdf');



%%
function pos_deg = pos2deg(position)
conversion_factor = 3.413;
pos_deg = (position-512)/conversion_factor;
end