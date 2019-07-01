function h=hinton_john(weights_simulations,parms,writeValues)

if nargin == 2
    writeValues = 0;
end

[h,fig_parms]=hinton_raw(weights_simulations);

hold on;
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize_lines = 13;
fontSize_columns = 13;

%column labels
y_shift_up = 0.75;
y_shift_bottom = 0.25;
x_shift = 0.5;

for i=1:parms.n_m
    text(2*i-1,y_max+y_shift_up,['M' num2str(i)],'FontSize',fontSize_columns,'HorizontalAlignment','center');
    text(2*i-0.5,y_max+y_shift_bottom,'+','FontSize',fontSize_columns,'HorizontalAlignment','center');
    text(2*i-1.5,y_max+y_shift_bottom,'-','FontSize',fontSize_columns,'HorizontalAlignment','center');   
    %text(2*i-1.5,y_max+y_shift,['M' num2str(i) '-'],'FontSize',fontSize_columns,'HorizontalAlignment','center');
    %text(2*i-0.5,y_max+y_shift,['M' num2str(i) '+'],'FontSize',fontSize_columns,'HorizontalAlignment','center');
    if i<parms.n_m
        plot([2*i 2*i],[y_min y_max],'k--')
    end
end

%line labels IMU
n_sensors = size(weights_simulations,1);
txt_IMU = {'Speed X','Speed Y','Speed Z','Gyro. Roll','Gyro. Pitch','Gyro. Yaw'};
for i=1:6
    text(x_min-x_shift,n_sensors+0.5-i,txt_IMU{i},'FontSize',fontSize_lines,'HorizontalAlignment','right');
end

%line labels loadcells
txt_loadcell = {' Z',' X',' Y'};
for channel=1:3
    for i=1:parms.n_lc
        text(x_min-x_shift,n_sensors-6*channel+0.5-i,['LC ' num2str(i) txt_loadcell{channel}],'FontSize',fontSize_lines,'HorizontalAlignment','right');
    end
    plot([x_min x_max],n_sensors-6*channel*[1 1],'k--')
end

xlim([x_min x_max]);
ylim([y_min y_max]);

ax=gca();
ax.Position = [0.01 0.01 1 0.95];

[n_sensors, n_motors] = size(weights_simulations);
fontSize_values=10;
if writeValues == 1
for i=1:n_sensors
    for j=1:n_motors
        value = weights_simulations(i,j);
        if value>0
            color = 'k';
        else
            color ='w';
        end
        text(j-0.5,n_sensors-i+0.5,num2str(value,'%.2f'),'FontSize',fontSize_values,'HorizontalAlignment','center','Color',color);
    end
end
end

h.Color = 'w';
hold off;
end
