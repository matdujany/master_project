clear; 
close all; clc;

%% Load data
addpath('../2_load_data_code');
addpath('computing_functions');
addpath('hinton_plot_functions');

recordID = 105;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);

weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis = read_weights_pos_robotis(recordID,parms);

weights_computed = compute_weights_wrapper(data,lpdata,parms,0,0,0,0);

%%
opt_parms.motor_list = [1:12];
opt_parms.lc_list = [3];
opt_parms.ylims = [-85 85];
f1=plot_weight_evolution_LC_both(weights_computed,parms,0,0,opt_parms);
f1.Position = 10^3*[0.0058    0.4210    1.5296    0.3410];
export_fig('figures_report/weight_conv_lc3_105.pdf',f1);


opt_parms.lc_list = [2];
opt_parms.ylims = [-85 85];
f2=plot_weight_evolution_LC_both(weights_computed,parms,0,0,opt_parms);
f2.Position = 10^3*[0.0058    0.4210    1.5296    0.3410];
export_fig('figures_report/weight_conv_lc2_105.pdf',f2);

%%
f_gyro=plot_weight_evolution_IMU(weights_robotis,parms,opt_parms);
f_gyro.Position = 10^3*[0.0058    0.4210    1.5296    0.3410];

% hidediag=true;
% plot_weight_pos_evolution(weights_pos_robotis,parms,hidediag);
export_fig('figures_report/weight_conv_gyro_105.pdf',f_gyro);

%%
hinton_LC(weights_computed{5},parms);

%%
weights_speed = compute_weights_speed(data,lpdata,parms);
opt_parms.ylims = 0.5*[-1 1];
f_speed=plot_weight_evolution_speed(weights_speed,parms,opt_parms);
f_speed.Position = 10^3*[0.0058    0.4210    1.5296    0.3410];
export_fig('figures_report/weight_conv_speed_105.pdf',f_speed);



%%
h=hinton_full_with_speed(weights_robotis,weights_speed,parms,0);
h.Position = [ 1           41         1536        749];
export_fig('figures_report/full_hinton_105.pdf',h);

%%
h=hinton_full_with_speed(weights_robotis,weights_speed,parms,1);
h.Position = [ 1           41         1536        749];
export_fig('figures_report/full_hinton_105_values.pdf',h);