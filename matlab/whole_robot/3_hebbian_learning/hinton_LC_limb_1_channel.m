function h = hinton_LC_limb_1_channel(channel_selected,weights_lc_fused_limb_order,parms,limb,writeValues)
%HINTON_LC Summary of this function goes here
%   Detailed explanation goes here

if nargin == 4
    writeValues = 0;
end

n_motors = parms.n_m;
n_sensors= parms.n_lc;
weights_lc_fused_limb_order_channel_selected = zeros(n_sensors,n_motors);
for i=1:n_sensors
    weights_lc_fused_limb_order_channel_selected(i,:) = weights_lc_fused_limb_order(channel_selected+3*(i-1),:);
end

[h,fig_parms] = hinton_raw(weights_lc_fused_limb_order_channel_selected);

x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize_lines = 14;
fontSize_columns = 14;

n_motors = parms.n_m;
n_sensors= parms.n_lc;

hold on;
%line labels loadcells
txt_loadcell = {' X',' Y',' Z'};
x_shift=0.25;
for i=1:n_sensors
    text(x_min-x_shift,n_sensors+0.5-i,['LC ' num2str(i) txt_loadcell{channel_selected}],'FontSize',fontSize_lines,'HorizontalAlignment','right');
end

%column labels
y_shift_up = 0.6;
y_shift_down = 0.3;
n_limb = size(limb,1);
for i=1:n_limb
    text(2*i-1,y_max+y_shift_up,['Limb ' num2str(i)],'FontSize',fontSize_columns,'HorizontalAlignment','center');
    for j=1:2
        text(2*i-2.5+j,y_max+y_shift_down,['M' num2str(limb(i,j))],'FontSize',fontSize_columns-1,'HorizontalAlignment','center');      
    end
    if i<n_limb
        plot(2*i*[1 1],[y_min y_max],'k--')
    end
end



hold off;
xlim([x_min x_max]);
ylim([y_min y_max]);
h.Color = 'w';
h. Position = [5 40 750 450];

fontSize_values = 12;
if writeValues
for i_motor=1:parms.n_m
    for i_channel=1:n_sensors
        value = weights_lc_fused_limb_order_channel_selected(i_channel,i_motor);
        if value<0
            color = 'w';
        else
            color = 'k';
        end
        stringnum = num2str(value,'%.1f');
%         stringnum = num2str(value,3);
        text(i_motor-0.5,n_sensors-i_channel+0.5,stringnum,'FontSize',fontSize_values,'HorizontalAlignment','center','Color',color);
    end
end
end

xlabel('weights fused over directions','FontSize',16)

end

