function h = hinton_IMU(weights,parms)
%HINTON_IMU Summary of this function goes here
%   Detailed explanation goes here

if nargin ==2
    writeValues = 0;
end

weights_IMU = weights(end-5:end,:);
[h,fig_parms] = hinton_raw(weights_IMU);

x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize_lines = 14;
fontSize_columns = 14;

n_motors = parms.n_m;
hold on;
for i=1:n_motors-1
    plot([2*i 2*i],[y_min y_max],'k--');
end

plot([x_min x_max],[3 3],'k--');

%line labels IMU
x_shift=0.25;
txt_IMU = {'Acc. X','Acc. Y','Acc. Z','Gyro. Roll','Gyro. Pitch','Gyro. Yaw'};
for i=1:6
    text(x_min-x_shift,6+0.5-i,txt_IMU{i},'FontSize',fontSize_lines,'HorizontalAlignment','right');
end

%column labels
y_shift_up = 0.5;
y_shift_bottom = 0.25;

for i=1:parms.n_m
    text(2*i-1,y_max+y_shift_up,['Motor ' num2str(i)],'FontSize',fontSize_columns,'HorizontalAlignment','center');
    text(2*i-0.5,y_max+y_shift_bottom,'+','FontSize',fontSize_columns,'HorizontalAlignment','center');
    text(2*i-1.5,y_max+y_shift_bottom,'-','FontSize',fontSize_columns,'HorizontalAlignment','center');   
    %text(2*i-1.5,y_max+y_shift,['M' num2str(i) '-'],'FontSize',fontSize_columns,'HorizontalAlignment','center');
    %text(2*i-0.5,y_max+y_shift,['M' num2str(i) '+'],'FontSize',fontSize_columns,'HorizontalAlignment','center');
    if i<parms.n_m
        plot([2*i 2*i],[y_min y_max],'k--')
    end
end
hold off;
xlim([x_min x_max]);
ylim([y_min y_max]);
h.Color = 'w';

ax=gca();
% ax.Position = [0.01 0.01 1 0.9];

end

