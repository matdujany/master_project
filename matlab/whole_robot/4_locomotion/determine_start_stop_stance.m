function [idx_start_stance,idx_stop_stance] = determine_start_stop_stance(GRF_limb,threshold_unloading)
%DETERMINE_START_STOP_STANCE Summary of this function goes here
%   Detailed explanation goes here

max_value_GRF_limb = quantile(GRF_limb,0.95);

idx_change_positions = find(diff(GRF_limb>threshold_unloading*max_value_GRF_limb)~=0);
if GRF_limb(1)>threshold_unloading*max_value_GRF_limb
    %GRF already over threshold at the beginning means it started in stance
    idx_start_stance = [1;idx_change_positions(2:2:end)];
    idx_stop_stance  = idx_change_positions(1:2:end);
else
    %it started in swing
    idx_start_stance = idx_change_positions(1:2:end);
    idx_stop_stance  = idx_change_positions(2:2:end);
end
if GRF_limb(end)>threshold_unloading
    %it ends in stance
    idx_stop_stance = [idx_stop_stance;length(GRF_limb)];
end

end

