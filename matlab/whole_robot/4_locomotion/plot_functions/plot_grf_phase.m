function plot_grf_phase(i_limb_plot,phi,GRF,index_start,index_stop,dot_size,t_start,t_stop)
title(['Reference for phase : Limb ' num2str(i_limb_plot) ' between ' num2str(t_start) 's and ' num2str(t_stop) 's']);
hold on;
n_limb = size(GRF,2);
for i=1:n_limb
    scatter(phi(index_start:index_stop,i_limb_plot),GRF(index_start:index_stop,i),dot_size,'filled');
    legend_list{i} = ['GRF ' num2str(i)];
end
legend(legend_list);
xlabel('\phi_{ref}');
xticks(pi/2*[0:4]);
xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
ylim([-1 10]);
ylabel('GRF [N]');
grid on;
end