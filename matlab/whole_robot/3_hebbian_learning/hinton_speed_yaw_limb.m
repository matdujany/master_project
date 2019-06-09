function h = hinton_speed_yaw_limb(weights_speed_limb_order,weights_yaw_limb_order,limb,writeValues)
%HINTON_LC Summary of this function goes here
%   Detailed explanation goes here


if nargin ==2
    writeValues = 0;
end

weights_grouped = [weights_speed_limb_order;weights_yaw_limb_order];
[h,fig_parms] = hinton_raw(weights_grouped);

hold on;
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
xlim([x_min x_max]);
fontSize = 16;

%line labels
x_shift = 0.1;
txt_list2 = {'X','Y','Z'};
for i=1:3
    text(x_min-x_shift,i+0.5,['Speed ' txt_list2{4-i}],'FontSize',fontSize,'HorizontalAlignment','right');
end
text(x_min-x_shift,0.5,'Gyro Yaw','FontSize',fontSize,'HorizontalAlignment','right');

%column labels
y_shift_up = 0.6;
y_shift_down = 0.3;
n_limb = size(limb,1);
for i=1:n_limb
    text(2*i-1,y_max+y_shift_up,['Limb ' num2str(i)],'FontSize',fontSize,'HorizontalAlignment','center');
    for j=1:2
        text(2*i-2.5+j,y_max+y_shift_down,['M' num2str(limb(i,j))],'FontSize',fontSize-1,'HorizontalAlignment','center');      
    end
    if i<n_limb
        plot(2*i*[1 1],[y_min y_max],'k--')
    end
end

fontSize_values = 12;
if writeValues
for i_motor=1:size(weights_speed_limb_order,2)
    for i_speed_channel=1:4
        value = weights_grouped(i_speed_channel,i_motor);
        if value<0
            color = 'w';
        else
            color = 'k';
        end
        stringnum = num2str(value,'%.1f');
%         stringnum = num2str(value,3);
        text(i_motor-0.5,4-i_speed_channel+0.5,stringnum,'FontSize',fontSize_values,'HorizontalAlignment','center','Color',color);
    end
end
end



h.Color = 'w';
h.Position = [10 10 800 400];
hold off;

% xlabel('Speed (integrated from IMU) weights averaged over the 2 directions','FontSize',fontSize);
end

