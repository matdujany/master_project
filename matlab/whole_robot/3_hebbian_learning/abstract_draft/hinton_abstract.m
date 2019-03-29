ylabelString='Loadcell 1 channels';
w=weights{parms.n_twitches}(1+3*(index_loadcell_plot-1):3*index_loadcell_plot,1:8);

fontSize = 20;

% Use no more than 640x480 pixels
xmax = 640; ymax = 480;

% Offset bottom left hand corner
x01 = 1000/2; y01 = 540/2;
%x02 = 1040; y02 = 580;

% Need to allow 5 pixels border for window frame: but 30 at top
border      = 5;
top_border  = 30;

ymax = ymax - top_border;
xmax = xmax - border;

% First layer

[xvals, yvals, color] = hintmat(w);
% Try to preserve aspect ratio approximately
if (8*size(w, 1) < 6*size(w, 2))
  delx = xmax; dely = xmax*size(w, 1)/(size(w, 2));
else
  delx = ymax*size(w, 2)/size(w, 1); dely = ymax;
end

x_min = min(min(xvals))-0.1;
x_max = max(max(xvals))+0.1;
y_min = min(min(yvals));
y_max = max(max(yvals));

% x_patch_bg = [x_min x_max x_max x_min];
% y_patch_bg = [y_min y_min y_max y_max];

h = figure('Name', 'Hinton diagram', ...
  'NumberTitle', 'off', ...
  'Colormap', [0 0 0; 1 1 1], ...
  'Units', 'pixels', ...
  'Position', [x01 y01 delx dely]);
set(gca, 'Position', [0 0 1 1]);
set(gca, 'units', 'normalized', 'OuterPosition', [0 0 1 1]);
hold on
patch(xvals', yvals', color', 'Edgecolor', 'none');
%patch(x_patch_bg, y_patch_bg, [0.5 0.5 0.5], 'Edgecolor', 'none');
set(findall(gca, 'type', 'text'), 'visible', 'on');
set(gca,'XTick',[],'YTick',[]);
set(gca,'Color',[0.5 0.5 0.5]);
set(gca, 'XColor', [0.5 0.5 0.5], 'YColor', [0.5 0.5 0.5]);
xlim([x_min x_max]);
ylim([y_min y_max]);
xlabel('Motor actions','FontSize',fontSize,'Color','k')
ylabel(ylabelString,'FontSize',fontSize,'Color','k');
axis equal;
hold off;
fig_parms.ymax = max(max(yvals));
fig_parms.ymin = min(min(yvals));
fig_parms.xmax = max(max(xvals));
fig_parms.xmin = min(min(xvals));



hold on;
plot([2 2],[fig_parms.ymin fig_parms.ymax],'k--');
plot([4 4],[fig_parms.ymin fig_parms.ymax],'k--','LineWidth',1.4);
plot([6 6],[fig_parms.ymin fig_parms.ymax],'k--');
hold off;

a = gca; % get the current axis;
a.Position(3) = 0.6;
% put the textbox at 75% of the width and 
% 10% of the height of the figure
% annotation('textbox', [0.75, 0.67, 0.05, 0.1],'String', "X",'FontSize',fontSize)
% annotation('textbox', [0.75, 0.47, 0.05, 0.1], 'String', "Y",'FontSize',fontSize)
% annotation('textbox', [0.75, 0.27, 0.05, 0.1], 'String', "Z",'FontSize',fontSize)
% 
% annotation('textbox', [0.2, 0.85, 0.1, 0.1], 'String', "Hip",'FontSize',fontSize)

annotation('textbox', [0.735, 0.67, 0.025, 0.05],'String', "X",'FontSize',fontSize,'FitBoxToText','on','Edgecolor', 'none')
annotation('textbox', [0.735, 0.515, 0.025, 0.05], 'String', "Y",'FontSize',fontSize,'FitBoxToText','on','Edgecolor', 'none')
annotation('textbox', [0.735, 0.36, 0.025, 0.05], 'String', "Z",'FontSize',fontSize,'FitBoxToText','on','Edgecolor', 'none')

%annotation('textbox', [0.2, 0.75, 0.1, 0.1], 'String', {'Hip 1'; 'Forward'},'FontSize',fontSize,'FitBoxToText','on')
annotation('textbox', [0.15, 0.72, 0.1, 0.1], 'String', {'hip1 -'},'FontSize',fontSize,'FitBoxToText','on','Edgecolor', 'none')
annotation('textbox', [0.22, 0.72, 0.1, 0.1], 'String', {'hip1 +'},'FontSize',fontSize,'FitBoxToText','on','Edgecolor', 'none')
annotation('textbox', [0.29, 0.72, 0.1, 0.1], 'String', {'knee1 -'},'FontSize',fontSize,'FitBoxToText','on','Edgecolor', 'none')
annotation('textbox', [0.366, 0.72, 0.1, 0.1], 'String', {'knee1 +'},'FontSize',fontSize,'FitBoxToText','on','Edgecolor', 'none')
annotation('textbox', [0.45, 0.72, 0.1, 0.1], 'String', {'hip2 -'},'FontSize',fontSize,'FitBoxToText','on','Edgecolor', 'none')
annotation('textbox', [0.52, 0.72, 0.1, 0.1], 'String', {'hip2 +'},'FontSize',fontSize,'FitBoxToText','on','Edgecolor', 'none')
annotation('textbox', [0.59, 0.72, 0.1, 0.1], 'String', {'knee2 -'},'FontSize',fontSize,'FitBoxToText','on','Edgecolor', 'none')
annotation('textbox', [0.666, 0.72, 0.1, 0.1], 'String', {'knee2 +'},'FontSize',fontSize,'FitBoxToText','on','Edgecolor', 'none')

set(h,'Position',[50 50 1920 1080]);
set(h,'PaperOrientation','landscape');
export_fig corr_mat_bigger.pdf

