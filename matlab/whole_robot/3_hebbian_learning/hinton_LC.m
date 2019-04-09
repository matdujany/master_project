function h = hinton_LC(weights,parms,writeValues)
%HINTON_LC Summary of this function goes here
%   Detailed explanation goes here

if nargin ==2
    writeValues = 0;
end

weights_lc = weights(1:parms.n_lc*parms.n_ch_lc,:);
[h,fig_parms] = hinton_raw(weights_lc);

x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize_lines = 14;
fontSize_columns = 14;

n_motors = parms.n_m;
n_sensors= parms.n_lc;

hold on;
for i=1:n_motors-1
    plot([2*i 2*i],[y_min y_max],'k--');
end
for i=1:n_sensors-1
     plot([x_min x_max],[parms.n_ch_lc*i parms.n_ch_lc*i],'k--');
end   

%line labels loadcells
txt_loadcell = {' X',' Y',' Z'};
x_shift=0.25;
for i=1:3*n_sensors
    text(x_min-x_shift,3*n_sensors+0.5-i,['Loadcell ' num2str(ceil(i/3)) txt_loadcell{mod(i-1,3)+1}],'FontSize',fontSize_lines,'HorizontalAlignment','right');
end

%column labels
y_shift_up = 0.5;
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
hold off;
xlim([x_min x_max]);
ylim([y_min y_max]);
h.Color = 'w';

fontSize_values = 12;
if writeValues
for i_motor=1:2*parms.n_m
    for i_channel=1:3*parms.n_lc
        value = weights_lc(i_channel,i_motor);
        if value<0
            color = 'w';
        else
            color = 'k';
        end
        text(i_motor-0.5,3*parms.n_lc-i_channel+0.5,num2str(10*value,'%.1f'),'FontSize',fontSize_values,'HorizontalAlignment','center','Color',color);
    end
end
end

end

