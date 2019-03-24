function f = plot_patch_learning(f,pos_start_learning,pos_end_learning)
%PLOT_PATCH_LEARNING Summary of this function goes here
%   f figure handle;
hold on;
ylimits = f.CurrentAxes.YLim;
y_patch_learning = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
for i=1:length(pos_start_learning)
    x_patch_learning = [pos_start_learning(i) pos_end_learning(i) pos_end_learning(i) pos_start_learning(i)];
    patch(x_patch_learning,y_patch_learning,'blue','FaceAlpha',0.1,'EdgeColor','none');
end
hold off;

