function h = hinton_LC_2(weights,parms,writeValues)
%HINTON_LC Summary of this function goes here
%   Detailed explanation goes here

if nargin ==2
    writeValues = 0;
end

weights_lc = weights(:,1:parms.n_lc*3);
[h,fig_parms] = hinton_raw(weights_lc);

hold on;
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize = 18;

%line labels
x_shift = 1.5;
for i=1:parms.n_m
    text(x_min-x_shift,2*i-0.5,['M' num2str(parms.n_m+1-i) ' -'],'FontSize',fontSize-2,'HorizontalAlignment','left');
    text(x_min-x_shift,2*(i-1)+0.5,['M' num2str(parms.n_m+1-i) ' +'],'FontSize',fontSize-2,'HorizontalAlignment','left');
    if i<parms.n_m
        plot([x_min x_max],[2*i 2*i],'k--')
    end
end

%column labels
y_shift_1 = 0.6;
y_shift_2 = 1.2;
for i=1:parms.n_lc
    text(3*(i-1)+1.5,y_max+y_shift_2,sprintf(['Loadcell ' num2str(i)]),'FontSize',fontSize-2,'HorizontalAlignment','center');
    if i<parms.n_lc
        plot([3*i 3*i],[y_min y_max],'k--');
    end
end

for i=1:parms.n_lc
    text(3*(i-1)+0.5,y_max+y_shift_1,'X','FontSize',fontSize-4,'HorizontalAlignment','center');
    text(3*(i-1)+1.5,y_max+y_shift_1,'Y','FontSize',fontSize-4,'HorizontalAlignment','center');
    text(3*(i-1)+2.5,y_max+y_shift_1,'Z','FontSize',fontSize-4,'HorizontalAlignment','center');
end

h.Color = 'w';

if writeValues
for i_motor=1:2*parms.n_m
    for i_channel=1:3*parms.n_lc
        value = weights_lc(2*parms.n_m+1-i_motor,i_channel);
        if value<0
            color = 'w';
        else
            color = 'k';
        end
        text(i_channel-0.5,i_motor-0.5,num2str(10*value,'%.1f'),'FontSize',fontSize-2,'HorizontalAlignment','center','Color',color);
    end
end
end

size_factor = 60;
h.Position = [10,10, size_factor*3*parms.n_lc, size_factor*2*parms.n_m];
hold off;
end

