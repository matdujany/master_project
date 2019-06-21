function h=plot_limb_to_lc_effect(weights_limb_summed,parms,titleString)

if nargin == 2
    titleString = '';
end

fontSize=16;
[h,fig_parms] = hinton_raw(weights_limb_summed);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
for i=1:parms.n_lc
    text(x_min-0.1,i-0.5,['LC ' num2str(parms.n_lc+1-i) ' Z'],'FontSize',fontSize,'HorizontalAlignment','right');
end
for i=1:parms.n_lc
    text(i-0.5,y_max+0.1,['Limb ' num2str(i)],'FontSize',fontSize,'HorizontalAlignment','center','VerticalAlignment','bottom');
    if i<parms.n_lc
        plot(i*[1 1],[y_min y_max],'k--');
    end
end
for i_limb=1:parms.n_lc
    for i_lc=1:parms.n_lc
        value = weights_limb_summed(i_limb,i_lc);
        if value>0
            color = 'k';
        else
            color = 'w';
        end
        text(i_lc-0.5,parms.n_lc-i_limb+0.5,num2str(value,'%.1f'),'Color',color,'FontSize',fontSize,'HorizontalAlignment','center');
    end
end
h.Color = 'w';
set(h,'Position',[10 10 700 700]);
set(h,'PaperOrientation','landscape');

xlabel(titleString,'FontSize',fontSize);

end