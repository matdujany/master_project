function h = hinton_LC(weights,parms)
%HINTON_LC Summary of this function goes here
%   Detailed explanation goes here
ylabelString = 'Loadcells (3 channels each)';
weights_LC = weights(1:parms.n_lc*parms.n_ch_lc,:);
[h,fig_parms]=hinton(weights_LC,ylabelString);

n_motors = parms.n_m;
n_sensors= parms.n_lc;

hold on;
for i=1:n_motors-1
    plot([2*i 2*i],[fig_parms.ymin fig_parms.ymax],'k--');
end
for i=1:n_sensors-1
     plot([fig_parms.xmin fig_parms.xmax],[parms.n_ch_lc*i parms.n_ch_lc*i],'k--');
end   
hold off;

end

