
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
weights = [weights_motor' weights_lc' weights_IMU'];
weights_rescaled = [weights_motor_rescaled' weights_lc_rescaled' weights_acc_rescaled' weights_gyro_rescaled'];

%%
addpath('../../export_fig');

h1 = hinton_limb(weights);
set(h1,'Position',[50 50 1920-200 1080-200]);
set(h1,'PaperOrientation','landscape');
export_fig 'figures_simon/hinton_limb_raw.pdf'

h2 = hinton_limb(weights_rescaled);
set(h2,'Position',[50 50 1920-200 1080-200]);
set(h2,'PaperOrientation','landscape');
export_fig 'figures_simon/hinton_limb_rescaled.pdf'

function h = hinton_limb(weights)
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
text(5.5,y_max+y_shift,sprintf('Accelero. X'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(6.5,y_max+y_shift,sprintf('Accelero. Y'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(7.5,y_max+y_shift,sprintf('Accelero. Z'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(8.5,y_max+y_shift,sprintf('Gyro. Roll'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(9.5,y_max+y_shift,sprintf('Gyro. Pitch'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(10.5,y_max+y_shift,sprintf('Gyro. Yaw'),'FontSize',fontSize-2,'HorizontalAlignment','center');
hold off;

h.Color = 'w';

end