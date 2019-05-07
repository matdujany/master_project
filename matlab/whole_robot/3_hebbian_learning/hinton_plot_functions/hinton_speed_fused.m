function h = hinton_speed_fused(weights_speed,parms,writeValues)
%HINTON_LC Summary of this function goes here
%   Detailed explanation goes here


if nargin ==2
    writeValues = 0;
end

[h,fig_parms] = hinton_raw(weights_speed);

hold on;
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize = 16;

%line labels
x_shift = 0.5;
txt_list2 = {'X','Y','Z'};
for i=1:3
    text(x_min-x_shift,i-0.5,txt_list2{4-i},'FontSize',fontSize,'HorizontalAlignment','left');
end

%column labels
y_shift = 0.3;
for i=1:parms.n_m
    text(i-0.5,y_max+y_shift,['M' num2str(i)],'FontSize',fontSize,'HorizontalAlignment','center');
end

fontSize_values = 12;
if writeValues
for i_motor=1:parms.n_m
    for i_speed_channel=1:3
        value = weights_speed(i_speed_channel,i_motor);
        if value<0
            color = 'w';
        else
            color = 'k';
        end
        stringnum = num2str(value,'%.1f');
%         stringnum = num2str(value,3);
        text(i_motor-0.5,3-i_speed_channel+0.5,stringnum,'FontSize',fontSize_values,'HorizontalAlignment','center','Color',color);
    end
end
end


h.Color = 'w';
h.Position = [10 10 600 300];
hold off;

xlabel('Speed (integrated from IMU) weights fused','FontSize',fontSize);
end

