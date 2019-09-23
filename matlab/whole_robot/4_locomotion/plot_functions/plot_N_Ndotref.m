function plot_N_Ndotref(i_limb_plot,phi,GRF,N_dot_filtered,index_start,index_stop,dot_size,t_start,t_stop)
title(['Reference for phase and N dot: Limb ' num2str(i_limb_plot) ' between ' num2str(t_start) 's and ' num2str(t_stop) 's']);
hold on;
n_limb = size(GRF,2);
for i=1:n_limb
    scatter(phi(index_start:index_stop,i_limb_plot),-N_dot_filtered(index_start:index_stop,i_limb_plot).*GRF(index_start:index_stop,i),dot_size,'filled');
    legend_list{i} = ['Limb ' num2str(i)];
end

legend(legend_list,'Location','southeast');
xticks(pi/2*[0:4]);
xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
xlabel('\phi_{ref}');
ylim(80*[-1 1]);
ylabel('-N * N dot filtered ref [N^2/s]');
grid on;
end