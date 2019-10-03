function subplot_time_signals(data,lpdata,index_start,index_end,index_motor_plot,index_loadcell_plot,index_channel_plot,parms,n_frames_theo,neutral_pos)
txt_channel_lc ={' X',' Y',' Z'};
% theoretical_traj = compute_theoretical_traj_wrapper(i_dir,parms);
hold on;
plot(pos2deg(lpdata.motor_position(index_motor_plot,index_start:index_end),neutral_pos),'b-');
plot(pos2deg(lpdata.motor_positionfiltered(index_motor_plot,index_start:index_end),neutral_pos),'b--');
% plot(theoretical_traj(n_frames_theo.part0 + 1:n_frames_theo.part0 + n_frames_theo.part1),'k-');
xlabel('Sample index');
ylabel(['Motor ' num2str(index_motor_plot) ' Position [deg]']);
%     for i=1:parms.n_m
%      plot(lpdata.motor_position(i,index_start:index_end));
%     end
yyaxis right;
%plot(data.float_value_dot_time{1,index_loadcell_plot}(index_start:index_end,channel),'--');
% plot(data.float_value_time{1,index_loadcell_plot}(index_start:index_end,3),'k-');
plot(data.float_value_time{1,index_loadcell_plot}(index_start:index_end,index_channel_plot),'r-');
plot(data.s_lc_filtered(index_start:index_end,index_channel_plot+3*(index_loadcell_plot-1)),'r--');
ylabel(['LC ' num2str(index_loadcell_plot) txt_channel_lc{index_channel_plot} ' [N]']);
hold off;
ax=gca();
ax.YAxis(1).Color = 'b';
ax.YAxis(2).Color = 'r';
xlim([0 n_frames_theo.part1+1]);
title('Time Signals in Learning Window');
end

function pos_deg = pos2deg(position,neutral_pos)
conversion_factor = 3.413;
if nargin == 1
    neutral_pos = 512;
end
pos_deg = (position-neutral_pos)/conversion_factor;
end