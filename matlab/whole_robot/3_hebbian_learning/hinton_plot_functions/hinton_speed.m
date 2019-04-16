function h = hinton_speed(weights_speed,parms)
%HINTON_LC Summary of this function goes here
%   Detailed explanation goes here

[h,fig_parms] = hinton_raw(weights_speed);

hold on;
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize = 15;

%line labels
x_shift = 0.5;
txt_list2 = {'X','Y','Z'};
for i=1:3
    text(x_min-x_shift,i-0.5,txt_list2{4-i},'FontSize',fontSize,'HorizontalAlignment','left');
end

%column labels
y_shift = 0.3;
for i=1:parms.n_m
    text(2*i-1.5,y_max+y_shift,['M' num2str(i) '-'],'FontSize',fontSize,'HorizontalAlignment','center');
    text(2*i-0.5,y_max+y_shift,['M' num2str(i) '+'],'FontSize',fontSize,'HorizontalAlignment','center');
    if i<parms.n_m
        plot([2*i 2*i],[y_min y_max],'k--')
    end
end

% %line labels
% x_shift = 1.5;
% for i=1:parms.n_m
%     text(x_min-x_shift,2*i-0.5,['M' num2str(parms.n_m+1-i) ' -'],'FontSize',fontSize-2,'HorizontalAlignment','left');
%     text(x_min-x_shift,2*(i-1)+0.5,['M' num2str(parms.n_m+1-i) ' +'],'FontSize',fontSize-2,'HorizontalAlignment','left');
%     if i<parms.n_m
%         plot([x_min x_max],[2*i 2*i],'k--')
%     end
% end
% 
% %column labels
% y_shift_1 = 0.6;
% y_shift_2 = 1.2;
% txt_list = {'Speed (integrated from IMU)'};
% text(1.5,y_max+y_shift_2,txt_list{1},'FontSize',fontSize-2,'HorizontalAlignment','center');
% 
% txt_list2 = {'X','Y','Z'};
% for i=1:3
%     text(i-0.5,y_max+y_shift_1,txt_list2{i},'FontSize',fontSize-4,'HorizontalAlignment','center');
% end

h.Color = 'w';
h.Position = [10 10 1000 350];
hold off;

xlabel('Speed weights, integrated from IMU','FontSize',fontSize);
end

