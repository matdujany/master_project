function plot_LC_dot_data(i_ard, data)

n_frames   = data.count_frames;
tmp        = data.float_value_dot_time{i_ard};
time       = data.time(1:end-1,i_ard);

str_title  = strcat("Arduino ", num2str(i_ard)); 

f_tmp      = figure;
fig        = gcf;
hold on
plot(time/1000,tmp,'LineWidth', 2);
ax        = gca;
line([ax.XLim],[0 0],'Color','black','LineStyle','--')
title(str_title);
set(f_tmp,'units','normalized','outerposition',[0.3 0.5 0.7 0.5])
legend('Sensor 1','Sensor 2','Sensor 3')
xlabel('Time [s]');
ylabel('Derivative of Load [kg/s]');
hold off;

end