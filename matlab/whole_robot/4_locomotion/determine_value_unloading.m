function [value_unloading,max_value_GRF_limb] = determine_value_unloading(GRF,threshold_unloading)
%DETERMINE_START_STOP_STANCE Summary of this function goes here
%   Detailed explanation goes here

for i_limb = 1:size(GRF,2)
    max_value_GRF_limb(i_limb) = quantile(GRF(:,i_limb),0.8);
end
value_unloading = threshold_unloading*max_value_GRF_limb;

