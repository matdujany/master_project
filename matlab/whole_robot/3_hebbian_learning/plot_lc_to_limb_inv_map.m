function h=plot_lc_to_limb_inv_map(inv_map,parms,titleString)

if nargin == 2
    titleString = '';
end

fontSize=16;
[h,fig_parms] = hinton_raw(inv_map);
x_min = fig_parms.xmin-0.1;
x_max = fig_parms.xmax+0.1;
y_min = fig_parms.ymin-0.1;
y_max = fig_parms.ymax+0.1;

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
for i=1:parms.n_lc
    %limb phase
    text(x_min-0.1,i-0.5,['$$ \dot{\phi_' num2str(parms.n_lc+1-i) '} $$'],'FontSize',fontSize+10,'HorizontalAlignment','right','Interpreter','latex');
    if i<parms.n_lc
        plot([x_min x_max],i*[1 1],'k--');
    end
end
for i=1:parms.n_lc
    %z lc 
    text(i-0.5,y_max+0.05,['$$ N_' num2str(i) '^V $$'],'FontSize',fontSize+4,'HorizontalAlignment','center','VerticalAlignment','bottom','Interpreter','latex');
end
for i_limb=1:parms.n_lc
    for i_lc=1:parms.n_lc
        value = inv_map(i_limb,i_lc);
        if value>0
            color = 'k';
        else
            color = 'w';
        end
        text(i_lc-0.5,parms.n_lc-i_limb+0.5,num2str(value,'%.3f'),'FontSize',fontSize-2,'HorizontalAlignment','center','Color',color);
    end
end

xlabel(titleString, 'FontSize',fontSize);

h.Color = 'w';
set(h,'Position',[10 10 700 700]);
set(h,'PaperOrientation','landscape');

end