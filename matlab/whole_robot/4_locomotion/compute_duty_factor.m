function duty_factor = compute_duty_factor(GRF,data,t_start,t_stop,threshold_unloading)
%COMPUTE_DUTY_FACTOR Summary of this function goes here
%   Detailed explanation goes here

n_limb = size(GRF,2);
duty_factor = zeros(n_limb,1);

for i_limb = 1:n_limb
    GRF_limb = GRF(:,i_limb);
    max_value_GRF_limb = quantile(GRF_limb,0.95);
    time_limb = (data.time(:,i_limb)-data.time(1,i_limb))/10^3;
    index_start = find(time_limb>t_start,1);
    index_stop = find(time_limb>t_stop,1);
    
    nb_samples_stance = sum(GRF_limb(index_start:index_stop)>threshold_unloading*max_value_GRF_limb);
    nb_samples = index_stop - index_start + 1;
    duty_factor(i_limb,1) = nb_samples_stance/nb_samples;
end

end


