function h=hinton_full_with_speed(weights_robotis,weights_speed,parms,writeValues)

if nargin == 3
    writeValues = 0;
end

n_iter = parms.n_twitches;
weights = weights_robotis{n_iter};

%% rescaling
weights_lc = weights(1:parms.n_lc*3,:);
weights_gyro = weights(parms.n_lc*3+4:parms.n_lc*3+6,:);
weights_speed = weights_speed{n_iter};

weights_rescaled = [rescale(weights_lc); rescale(weights_speed); rescale(weights_gyro)];

[h,fig_parms]=hinton_raw(weights_rescaled);
hold on;
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize_lines = 13;
fontSize_columns = 13;

%column labels
y_shift_up = 0.55;
y_shift_bottom = 0.25;

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
%
%line labels motors
n_sensors = size(weights_rescaled,1);
x_shift = 0.25;

%line labels loadcells
txt_loadcell = {' X',' Y',' Z'};
for i=1:3*parms.n_lc
    text(x_min-x_shift,n_sensors+0.5-i,['LC ' num2str(ceil(i/3)) txt_loadcell{mod(i-1,3)+1}],'FontSize',fontSize_lines,'HorizontalAlignment','right');
end
for i=1:parms.n_lc+1
    plot([x_min x_max],n_sensors-3*i + [0 0],'k--')
end

%line labels IMU
txt_speed = {'Speed X','Speed Y','Speed Z'};
for i=1:3
    text(x_min-x_shift,n_sensors-3*parms.n_lc+0.5-i,txt_speed{i},'FontSize',fontSize_lines,'HorizontalAlignment','right');
end

txt_gyro = {'Gyro. Roll','Gyro. Pitch','Gyro. Yaw'};
for i=1:3
    text(x_min-x_shift,n_sensors-3*parms.n_lc-3+0.5-i,txt_gyro{i},'FontSize',fontSize_lines,'HorizontalAlignment','right');
end

xlim([x_min x_max]);
ylim([y_min y_max]);

ax=gca();
ax.Position = [0.2 0.01 0.79 0.9];

[n_sensors, n_motors] = size(weights_rescaled);
fontSize_values=10;
if writeValues == 1
for i=1:n_sensors
    for j=1:n_motors
        value = weights_rescaled(i,j);
        if value>0
            color = 'k';
        else
            color ='w';
        end
        text(j-0.5,n_sensors-i+0.5,num2str(value,'%.0f'),'FontSize',fontSize_values,'HorizontalAlignment','center','Color',color);
    end
end
end

h.Color = 'w';
hold off;
end

function weights_rescaled = rescale(weights)
weights_rescaled = 100*weights/(max(max(abs(weights))));
end