
clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');

%% Load data

recordID = 12;
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
idx_lc_channels = 3*(lc_selected-1)+[1:3]
disp('Index motor weight matrices');
idx_motor_wm = 2*motor_selected(1)-1:2*motor_selected(2)

weights_lc = weights_read{n_iter}(idx_lc_channels,idx_motor_wm);
weights_IMU = weights_read{n_iter}(end-5:end,idx_motor_wm);
weights_motor = weights_pos_read{n_iter}(motor_selected,idx_motor_wm);

%%
weights = [weights_motor' weights_lc' weights_IMU'];

%%
fontSize = 20;
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
x_shift1 = 0.2;
text(x_min-x_shift1,3.5,'Hip +','FontSize',fontSize-2,'HorizontalAlignment','right');
text(x_min-x_shift1,2.5,'Hip -','FontSize',fontSize-2,'HorizontalAlignment','right');
text(x_min-x_shift1,1.5,'Knee +','FontSize',fontSize-2,'HorizontalAlignment','right');
text(x_min-x_shift1,0.5,'Knee -','FontSize',fontSize-2,'HorizontalAlignment','right');

y_shift = 0.5;
text(0.5,y_max+y_shift,'Hip','FontSize',fontSize-2,'HorizontalAlignment','center');
text(1.5,y_max+y_shift,'Knee','FontSize',fontSize-2,'HorizontalAlignment','center');
text(2.5,y_max+y_shift,sprintf('Loadcell\nchannel 1'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(3.5,y_max+y_shift,sprintf('Loadcell\nchannel 2'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(4.5,y_max+y_shift,sprintf('Loadcell\nchannel 3'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(5.5,y_max+y_shift,sprintf('Accelero.\nchannel 1'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(6.5,y_max+y_shift,sprintf('Accelero.\nchannel 2'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(7.5,y_max+y_shift,sprintf('Accelero.\nchannel 3'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(8.5,y_max+y_shift,sprintf('Gyroscope\nchannel 1'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(9.5,y_max+y_shift,sprintf('Gyroscope\nchannel 2'),'FontSize',fontSize-2,'HorizontalAlignment','center');
text(10.5,y_max+y_shift,sprintf('Gyroscope\nchannel 3'),'FontSize',fontSize-2,'HorizontalAlignment','center');
hold off;

%%
%addpath('../../export_fig');
%set(h,'PaperOrientation','landscape');
%export_fig 'hinton_limb.pdf'
