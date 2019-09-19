function h=plot_inv_map_Ny_knee_only(weights_inv_map)

fontSize=18;
[h,fig_parms] = hinton_raw(weights_inv_map);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

n_limb = size(weights_inv_map,1);
n_lc = size(weights_inv_map,2);

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);

for i=1:n_limb
    %limb phase
    text(x_min-0.1,i-0.5,['$$ \dot{\phi_' num2str(n_limb+1-i) '} $$'],'FontSize',fontSize+10,'HorizontalAlignment','right','Interpreter','latex');
    if i<n_limb
        plot([x_min x_max],i*[1 1],'k--');
    end
end

for i=1:n_lc
    %z lc 
    text(i-0.5,y_max+0.05,['$$ F_' num2str(i) ' $$'],'FontSize',fontSize+4,'HorizontalAlignment','center','VerticalAlignment','bottom','Interpreter','latex');
end

for i_limb=1:n_limb
    for i_lc=1:n_lc
        value = weights_inv_map(i_limb,i_lc);
        if value>0
            color = 'k';
        else
            color = 'w';
        end
        text(i_lc-0.5,n_lc-i_limb+0.5,num2str(value,'%.1f'),'FontSize',fontSize-2,'HorizontalAlignment','center','Color',color);
    end
end

text((x_min+x_max)/2,-0.5,'$$ \dot{\phi_i} = \omega - \sigma_p\sum_{all\ j} v_{i,j}^{knee} F_j sin(\phi_i),   (\sigma_p>0) $$','FontSize',fontSize+5,'HorizontalAlignment','center','Interpreter','latex');
text(-0.5,y_max+0.2,'$$ v_{i,j}^{knee} $$','FontSize',fontSize+5,'HorizontalAlignment','center','Interpreter','latex');


h.Color = 'w';
set(h,'Position',[10 10 700 700]);
set(h,'PaperOrientation','landscape');

end