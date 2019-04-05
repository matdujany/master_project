function f = plot_patch_learning(f,pos_start_learning,pos_end_learning,flagText)
%PLOT_PATCH_LEARNING Summary of this function goes here
%   f figure handle;
if nargin == 3
    flagText = 0;
end
hold on;
ylimits = f.CurrentAxes.YLim;
y_patch_learning = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
counts = 0;
txt_list = {'Hip -','Hip +', 'Knee -', 'Knee +'};

for i=1:length(pos_start_learning)
    x_patch_learning = [pos_start_learning(i) pos_end_learning(i) pos_end_learning(i) pos_start_learning(i)];
    patch(x_patch_learning,y_patch_learning,'blue','FaceAlpha',0.1,'EdgeColor','none');
    if flagText == 1
        text(mean(x_patch_learning),ylimits(2)-1,txt_list(mod(counts,4)+1),'FontSize',14,'HorizontalAlignment','center');
        text(mean(x_patch_learning),ylimits(2)-0.5,['M' num2str(ceil((counts+1)/2))],'FontSize',14,'HorizontalAlignment','center');
    end
    counts = counts+1;
end
hold off;

