function plot_stance_patches(phi,ax,time)
%PLOT_STANCE_PATCHES Summary of this function goes here
%   Detailed explanation goes here

ylims = ax.YLim;
boolSwitchTime = true;
if nargin == 2
    boolSwitchTime = false;
end

sin_phi_limb = sin(phi);
idx_change_positions = find(diff(sin_phi_limb<0)~=0);
if sin_phi_limb(1)<0
    %sin phi already neg at the beginning means it started in stance
    idx_start_stance = [1 idx_change_positions(2:2:end)];
    idx_stop_stance  = idx_change_positions(1:2:end);
else
    %it started in swing
    idx_start_stance = idx_change_positions(1:2:end);
    idx_stop_stance  = idx_change_positions(2:2:end);
end
if sin_phi_limb(end)<0
    %it ends in stance
    idx_stop_stance = [idx_stop_stance length(sin_phi_limb)];
end

for i=1:length(idx_start_stance)
    y_patch = [ylims(1) ylims(1) ylims(2) ylims(2)]; 
    x_patch = [idx_start_stance(i) idx_stop_stance(i) idx_stop_stance(i) idx_start_stance(i)];
    if boolSwitchTime 
        x_patch = time(x_patch);
    end
    patch(x_patch,y_patch,'b','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
end

end

