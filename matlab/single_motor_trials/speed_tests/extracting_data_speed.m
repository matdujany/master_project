clear;close all;

fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.4;

% name = 'speed_6_9Hz.fig';
name = 'speed_6Hz.fig';
open(name) 
D=get(gca,'Children'); %get the handle of the line object
XData=get(D,'XData');
YData=get(D,'YData');

f=figure;
hold on;
plot(XData{1}/1000,pos2deg(YData{1}),'LineWidth',lineWidth);
plot(XData{2}/1000,pos2deg(YData{2}),'LineWidth',lineWidth);
ylim([-65 65]);
ylabel('Position [deg]','FontSize',fontSize);
xlabel('Time [s]','FontSize',fontSize);
% lgd=legend({'Goal Position (frequency linearly increasing from 0.95 Hz to 1.4 Hz)', 'Actual Position'},'FontSize',fontSize);
lgd=legend({'Goal Position (frequency 0.95 Hz)', 'Actual Position'},'FontSize',fontSize);
lgd.NumColumns = 2;
f.Color = 'w';
f.Position = [538         425        1034         553];
lgd.Position = [0.1396    0.9355    0.7573    0.0506];
ax =gca();
ax.FontSize = fontSizeTicks;

% export_fig 'limit_frequency_increasing_speed.pdf'
export_fig 'limit_frequency_speed.pdf'

function pos_deg = pos2deg(position)
conversion_factor = 3.413;
pos_deg = (position-512)/conversion_factor;
end