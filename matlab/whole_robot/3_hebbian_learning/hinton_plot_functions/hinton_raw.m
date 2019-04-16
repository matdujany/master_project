function [h,fig_parms] = hinton_raw(w)
%HINTON	Plot Hinton diagram for a weight matrix.
%
%	Description
%
%	HINTON(W) takes a matrix W and plots the Hinton diagram.
%
%	H = HINTON(NET) also returns the figure handle H which can be used,
%	for instance, to delete the  figure when it is no longer needed.
%
%	To print the figure correctly in black and white, you should call
%	SET(H, 'INVERTHARDCOPY', 'OFF') before printing.
%
%	See also
%	DEMHINT, HINTMAT, MLPHINT
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Set scale to be up to 0.9 of maximum absolute weight value, where scale
% defined so that area of box proportional to weight value.

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


h = figure('Name', 'Hinton diagram', 'NumberTitle', 'off', 'Colormap', [0 0 0; 1 1 1], 'Units', 'pixels','Position', [x01 y01 delx dely]);
%h = figure('Name', 'Hinton diagram', 'NumberTitle', 'off', 'Colormap', [0 0 0; 1 1 1], 'Units', 'pixels');

set(gca, 'Position', [0 0 1 1]);
set(gca, 'units', 'normalized', 'OuterPosition', [0 0 1 1]);
hold on
patch(xvals', yvals', color', 'Edgecolor', 'none');
set(findall(gca, 'type', 'text'), 'visible', 'on');
set(gca,'XTick',[],'YTick',[]);
set(gca,'Color',[0.5 0.5 0.5]);
set(gca, 'XColor', [0.5 0.5 0.5], 'YColor', [0.5 0.5 0.5]);
axis equal;

hold off;

fig_parms.ymax = max(max(yvals));
fig_parms.ymin = min(min(yvals));
fig_parms.xmax = max(max(xvals));
fig_parms.xmin = min(min(xvals));