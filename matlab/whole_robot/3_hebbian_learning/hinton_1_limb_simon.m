
clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');

%% Load data

recordID = 15;
n_iter = 5;

[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_read = read_weights_robotis(recordID,parms);
weights_pos_read = read_weights_pos_robotis(recordID,parms);

loadcell_indexes = [3;4;1;2];
motor_indexes = [1 2;3 4;5 6;7 8];

idx_limb = 1;

motor_selected = motor_indexes(idx_limb,:);
lc_selected = loadcell_indexes(idx_limb);
disp('Index loadcell channels');
idx_lc_channels = 3*(lc_selected-1)+[1:3];
disp('Index motor weight matrices');
idx_motor_wm = 2*motor_selected(1)-1:2*motor_selected(2);

weights_lc = weights_read{n_iter}(idx_lc_channels,idx_motor_wm);
weights_IMU = weights_read{n_iter}(end-5:end,idx_motor_wm);
weights_motor = weights_pos_read{n_iter}(motor_selected,idx_motor_wm);

renorm_pos = max(max(abs(weights_pos_read{n_iter})));
renorm_lc = max(max(abs(weights_read{n_iter}(1:3*(parms.nr_arduino),:))));
renorm_imu = max(max(abs(weights_read{n_iter}(3*(parms.nr_arduino)+1:3*(parms.nr_arduino)+3,:))));
renorm_gyro = max(max(abs(weights_read{n_iter}(3*(parms.nr_arduino)+4:3*(parms.nr_arduino)+6,:))));

weights_motor_rescaled = weights_motor/renorm_pos;
weights_lc_rescaled = weights_lc/renorm_lc;
weights_acc_rescaled = weights_IMU(1:3,:)/renorm_imu;
weights_gyro_rescaled = weights_IMU(4:6,:)/renorm_gyro;

%%
weights = [weights_motor; weights_lc; weights_IMU];
weights_rescaled = [weights_motor_rescaled; weights_lc_rescaled; weights_acc_rescaled; weights_gyro_rescaled];

%%
addpath('../../export_fig');
%%
% h1 = hinton_limb(weights,parms,0);
h1 = hinton_limb_2(weights',0);

set(h1,'Position',[10 10 600 1000]);
% set(h1,'PaperOrientation','landscape');
% export_fig 'figures_simon/hinton_limb_raw.pdf'

%%
% h2 = hinton_limb(weights_rescaled,parms,1);
h2 = hinton_limb_2(weights_rescaled',1);

set(h2,'Position',[10 10 600 1000]);
% set(h2,'PaperOrientation','landscape');
% export_fig 'figures_simon/hinton_limb_rescaled.pdf'

%%
function h = hinton_limb(weights,parms,writeValues)
fontSize = 18;
[h,fig_parms] = hinton_raw(weights);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
motor_dir_txt = {'-','+'};
y_shift = 0.3;
for i=1:size(weights,2)
    text(i-0.5,y_max+y_shift,['M' num2str(ceil(i/2)) motor_dir_txt{1+mod(i-1,2)}],'FontSize',fontSize-2,'HorizontalAlignment','center');
end
plot([2 2],[y_min y_max],'k--');

x_shift = 0.15;
row_names_list = {'Motor 1','Motor 2','Loadcell 3 X','Loadcell 3 Y','Loadcell 3 Z','Acc. X','Acc. Y','Acc. Z','Gyro. Roll','Gyro. Pitch','Gyro. Yaw'};
for i=1:size(weights,1)
    text(x_min-x_shift,size(weights,1)-i+0.5,row_names_list{i},'FontSize',fontSize-2,'HorizontalAlignment','right');
end

plot([x_min x_max],[3 3],'k--');
plot([x_min x_max],[6 6],'k--');
plot([x_min x_max],[9 9],'k--');


h.Color = 'w';

if writeValues
[n_motors, n_sensors] = size(weights);
for i=1:n_motors
    for j=1:n_sensors
        value = weights(i,j);
        if value>0
            color = 'k';
        else
            color = 'w';
        end
        text(j-0.5,n_motors-i+0.5,num2str(value,'%.2f'),'FontSize',fontSize-2,'HorizontalAlignment','center','Color',color);
    end
end
end

end



function h = hinton_limb_2(weights,writeValues)
fontSize = 18;
[h,fig_parms] = hinton_raw(weights);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
plot([x_min x_max],[2 2],'k--')
plot([2 2],[y_min y_max],'k--')
plot([5 5],[y_min y_max],'k--')
plot([8 8],[y_min y_max],'k--')
x_shift1 = 0.15;
text(x_min-x_shift1,3.5,'Motor 1 -','FontSize',fontSize-2,'HorizontalAlignment','right');
text(x_min-x_shift1,2.5,'Motor 1 +','FontSize',fontSize-2,'HorizontalAlignment','right');
text(x_min-x_shift1,1.5,'Motor 2 -','FontSize',fontSize-2,'HorizontalAlignment','right');
text(x_min-x_shift1,0.5,'Motor 2 +','FontSize',fontSize-2,'HorizontalAlignment','right');

y_shift = 0.15;
text(0.5,y_max+y_shift,'   Motor 1','FontSize',fontSize-2,'HorizontalAlignment','center');
text(1.5,y_max+y_shift,'Motor 2','FontSize',fontSize-2,'HorizontalAlignment','center');
text(2.5,y_max+y_shift,sprintf('Loadcell X'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(3.5,y_max+y_shift,sprintf('Loadcell Y'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(4.5,y_max+y_shift,sprintf('Loadcell Z'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(5.5,y_max+y_shift,sprintf('Acc. X'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(6.5,y_max+y_shift,sprintf('Acc. Y'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(7.5,y_max+y_shift,sprintf('Acc. Z'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(8.5,y_max+y_shift,sprintf('Roll'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(9.5,y_max+y_shift,sprintf('Pitch'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(10.5,y_max+y_shift,sprintf('Yaw'),'FontSize',fontSize-2,'HorizontalAlignment','center');
hold off;

h.Color = 'w';

if writeValues
[n_motors, n_sensors] = size(weights);
for i=1:n_motors
    for j=1:n_sensors
        value = weights(i,j);
        if value>0
            color = 'k';
        else
            color = 'w';
        end
        text(j-0.5,n_motors-i+0.5,num2str(value,'%.2f'),'FontSize',fontSize-2,'HorizontalAlignment','center','Color',color);
    end
end
end

end
