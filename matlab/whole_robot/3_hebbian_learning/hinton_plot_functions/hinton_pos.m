function h = hinton_pos(weights_pos,parms,hidediag)
%HINTON_LC Summary of this function goes here
%   Detailed explanation goes here
ylabelString = 'motor position sensor';
if hidediag
    for i=1:parms.n_m
        weights_pos(i,1+2*(i-1))=0;
        weights_pos(i,2*i)=0;
    end
end
[h,fig_parms]=hinton(weights_pos,ylabelString);

n_motors = parms.n_m;

hold on;
for i=1:n_motors-1
    plot([2*i 2*i],[fig_parms.ymin fig_parms.ymax],'k--');
end
for i=1:n_motors-1
     plot([fig_parms.xmin fig_parms.xmax],[i i],'k--');
end   
hold off;

end

