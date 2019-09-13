function subplot_dot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_plot,sign_learning,n_frames_theo)
conversion_factor = 3.413;
txt_channel_lc ={' X',' Y',' Z'};
hold on;
plot(sign_learning*lpdata.m_s_dot_pos(index_motor_plot,index_start:index_end)/conversion_factor,'b-');
plot(sign_learning*lpdata.m_s_dot_posfiltered(index_motor_plot,index_start:index_end)/conversion_factor,'b--');
plot([0 n_frames_theo.part1+1],[0.02 0.02],'Color',[0,0,1,0.2]);
xlabel('Sample index');
ylabel(['Motor ' num2str(index_motor_plot) ' speed [deg/ms]']);
ylim([-0.05 0.05]);
yyaxis right;
plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,index_channel_plot),'r-');
plot(data.s_dot_lc_filtered(index_start:index_end,index_channel_plot+3*(index_loadcell_plot-1)),'r--');
plot([0 n_frames_theo.part1+1],[0 0],'Color',[1,0,0,0.2]);
ylabel(['LC ' num2str(index_loadcell_plot) txt_channel_lc{index_channel_plot} 'differentiated [N/s]']);
%ylim([-100 100]);
xlim([0 n_frames_theo.part1+1]);
ax=gca();
ax.YAxis(1).Color = 'b';
ax.YAxis(2).Color = 'r';
ax.YAxis(2).Limits=max(abs(ax.YAxis(2).Limits))*[-1 1];
hold off;
title('Differentiated Signals in Learning Window');
end