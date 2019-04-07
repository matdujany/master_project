function h = hinton_pos_2(weights_pos,parms,hidediag)
%HINTON_LC Summary of this function goes here
%   Detailed explanation goes here
if hidediag
    for i=1:parms.n_m
        weights_pos(i,1+2*(i-1))=0;
        weights_pos(i,2*i)=0;
    end
end
[h,fig_parms] = hinton_raw(weights_pos);

n_motors = parms.n_m;

hold on;
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize = 18;

%line labels
x_shift = 1.5;
for i=1:parms.n_m
    text(x_min-x_shift,2*i-0.5,['M' num2str(parms.n_m+1-i) ' +'],'FontSize',fontSize-2,'HorizontalAlignment','left');
    text(x_min-x_shift,2*(i-1)+0.5,['M' num2str(parms.n_m+1-i) ' -'],'FontSize',fontSize-2,'HorizontalAlignment','left');
    if i<parms.n_m
        plot([x_min x_max],[2*i 2*i],'k--')
    end
end

%column labels
y_shift_motors = 0.9;
for i=1:parms.n_m
    text(i,y_max+y_shift_motors,['M' num2str(i)],'FontSize',fontSize-2,'HorizontalAlignment','right');
end

h.Color = 'w';
hold off;

end

