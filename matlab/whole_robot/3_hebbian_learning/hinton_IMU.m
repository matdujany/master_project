function h = hinton_IMU(weights,parms)
%HINTON_IMU Summary of this function goes here
%   Detailed explanation goes here
ylabelString = 'IMU (4 channels)';
weights_IMU = weights(end-parms.n_useful_ch_IMU+1:end,:);
[h,fig_parms]=hinton(weights_IMU, ylabelString);

n_motors = parms.n_m;
hold on;
for i=1:n_motors-1
    plot([2*i 2*i],[fig_parms.ymin fig_parms.ymax],'k--');
end
hold off;

end

