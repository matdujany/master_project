function h=plot_weights_limb_assignment(weights_fused_limbass,parms)
fontSize=16;
[h,fig_parms] = hinton_raw(weights_fused_limbass);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
for i=1:parms.n_lc
    text(x_min-0.1,i-0.5,['LC ' num2str(parms.n_lc+1-i)],'FontSize',fontSize,'HorizontalAlignment','right');
end
for i=1:parms.n_m
    text(i-0.5,y_max+0.1,['M' num2str(i)],'FontSize',fontSize,'HorizontalAlignment','center','VerticalAlignment','bottom');
    plot([i i],[y_min y_max],'k--');    
end
h.Color = 'w';

for i_motor=1:parms.n_m
    for i_lc=1:parms.n_lc
        text(i_motor-0.5,parms.n_lc-i_lc+0.5,num2str(weights_fused_limbass(i_lc,i_motor),'%.0f'),'FontSize',fontSize-2,'HorizontalAlignment','center');
    end
end

set(h,'Position',[10 10 1000 700]);
set(h,'PaperOrientation','landscape');
end