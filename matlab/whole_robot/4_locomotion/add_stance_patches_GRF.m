function add_stance_patches_GRF(GRF_limb,ax,time,color)
%PLOT_STANCE_PATCHES Summary of this function goes here
%   Detailed explanation goes here

ylims = ax.YLim;
boolSwitchTime = true;
if nargin == 2
    boolSwitchTime = false;
    color = 'b';
end

if nargin == 3
    color = 'b';
end


threshold_unloading = 0.5;
[idx_start_stance,idx_stop_stance] = determine_start_stop_stance(GRF_limb,threshold_unloading);

for i=1:length(idx_start_stance)
    y_patch = [ylims(1) ylims(1) ylims(2) ylims(2)]; 
    x_patch = [idx_start_stance(i) idx_stop_stance(i) idx_stop_stance(i) idx_start_stance(i)];
    if boolSwitchTime 
        x_patch = time(x_patch);
    end
    patch(x_patch,y_patch,color,'FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
end


end

