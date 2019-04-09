function h = hinton_IMU_2(weights,parms)
%HINTON_LC Summary of this function goes here
%   Detailed explanation goes here

weights_IMU = weights(:,end-5:end);
[h,fig_parms] = hinton_raw(weights_IMU);

hold on;
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize = 18;

%line labels
x_shift = 1.5;
for i=1:parms.n_m
    text(x_min-x_shift,2*i-0.5,['M' num2str(parms.n_m+1-i) ' -'],'FontSize',fontSize-2,'HorizontalAlignment','left');
    text(x_min-x_shift,2*(i-1)+0.5,['M' num2str(parms.n_m+1-i) ' +'],'FontSize',fontSize-2,'HorizontalAlignment','left');
    if i<parms.n_m
        plot([x_min x_max],[2*i 2*i],'k--')
    end
end

%column labels
y_shift_1 = 0.6;
y_shift_2 = 1.2;
txt_list = {'Accelero.','Gyro.'};
for i=1:2
    text(3*(i-1)+1.5,y_max+y_shift_2,txt_list{i},'FontSize',fontSize-2,'HorizontalAlignment','center');
end
plot([3 3],[y_min y_max],'k--');

txt_list2 = {'X','Y','Z','Roll','Pitch','Yaw'};
for i=1:6
    text(i-0.5,y_max+y_shift_1,txt_list2{i},'FontSize',fontSize-4,'HorizontalAlignment','center');
end

h.Color = 'w';
h.Position = [10 10 400 900];
hold off;
end

