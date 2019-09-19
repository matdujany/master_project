function h=plot_Nz_dot_alpha_dot(weights_lcz_hip,motorTypeString)


fontSize=18;
[h,fig_parms] = hinton_raw(weights_lcz_hip);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

n_lc = size(weights_lcz_hip,1);
n_motors = size(weights_lcz_hip,2);

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
for i=1:n_lc
    text(x_min-0.1,i-0.5,['N_{' num2str(n_lc+1-i) '}'],'FontSize',fontSize,'HorizontalAlignment','right');
end
for i=1:n_motors
    text(i-0.5,y_max+0.1,['\alpha_{' motorTypeString num2str(i) '}'],'FontSize',fontSize,'HorizontalAlignment','center','VerticalAlignment','bottom');
    if i<n_motors
        plot(i*[1 1],[y_min y_max],'k--');
    end
end
text(0,y_max+0.1,'dN/d\alpha','FontSize',fontSize,'HorizontalAlignment','right','VerticalAlignment','bottom');
for i_motor=1:n_motors
    for i_lc=1:n_lc
        value = weights_lcz_hip(i_motor,i_lc);
        if value>0
            color = 'k';
        else
            color = 'w';
        end
        text(i_lc-0.5,n_lc-i_motor+0.5,num2str(value,'%.1f'),'Color',color,'FontSize',fontSize-2,'HorizontalAlignment','center');
    end
end

h.Color = 'w';
set(h,'Position',[10 10 700 700]);
set(h,'PaperOrientation','landscape');

% xlabel(titleString,'FontSize',fontSize);

end