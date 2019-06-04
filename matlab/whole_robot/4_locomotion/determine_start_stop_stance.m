function [idx_start_stance,idx_stop_stance] = determine_start_stop_stance(GRF_limb,threshold_unloading)
%DETERMINE_START_STOP_STANCE Summary of this function goes here
%   Detailed explanation goes here

value_unloading = determine_value_unloading(GRF_limb,threshold_unloading);

idx_change_positions = find(diff(GRF_limb>value_unloading)~=0);
if GRF_limb(1)>value_unloading
    %GRF already over threshold at the beginning means it started in stance
    idx_start_stance = [1;idx_change_positions(2:2:end)];
    idx_stop_stance  = idx_change_positions(1:2:end);
else
    %it started in swing
    idx_start_stance = idx_change_positions(1:2:end);
    idx_stop_stance  = idx_change_positions(2:2:end);
end
if GRF_limb(end)>value_unloading
    %it ends in stance
    idx_stop_stance = [idx_stop_stance;length(GRF_limb)];
end

end

