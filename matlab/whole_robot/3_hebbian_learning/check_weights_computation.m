
clear; 
close all; clc;

addpath('learning_functions');
addpath('../2_load_data_code');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data

record_list = 220;
max_dif_lc = zeros(1,length(record_list));
max_dif_speed = zeros(1,length(record_list));
max_dif_gyro = zeros(1,length(record_list));

n_iter = 5;

flagPlot = 0;
flagFiltersim = 0;

for idx=1:length(record_list)
    recordID = record_list(idx);
    [data, lpdata, parms] =  load_data_processed(recordID);
%     parms=add_parms(parms);
    weights_check = compute_weights_wrapper(data,lpdata,parms,1,0,flagPlot,0,0);
    weights_read = read_weights_robotis(recordID,parms);
    
    for k=1:parms.n_twitches
        weights_lc_robotis{k} = weights_read{k}(1:end-6,:);
        weights_speed_robotis{k} = weights_read{k}(end-5:end-3,:);
        weights_gyro_robotis{k} = weights_read{k}(end-2:end,:);
        weights_lc_check{k} = weights_check{k}(1:end-6,:);
        weights_gyro_check{k} = weights_check{k}(end-2:end,:);        
    end
    weights_speed_check = compute_weights_speed(data,lpdata,parms);

    max_dif_lc(1,idx) = check_weights_diff(weights_check,weights_lc_robotis,n_iter);
    max_dif_speed(1,idx) = check_weights_diff(weights_speed_check,weights_speed_robotis,n_iter);
    max_dif_gyro(1,idx) = check_weights_diff(weights_gyro_check,weights_gyro_robotis,n_iter);
    
%     weights_pos_check = compute_weights_pos_wrapper(data,lpdata,parms,0,flagPlot);
%     weights_pos_read = read_weights_pos_robotis(recordID,parms);
%     max_dif_norm_pos(1,idx) = check_weights_diff(weights_pos_check,weights_pos_read,n_iter);

end

%%
n_iter = 5;
diff_lc = (weights_lc_robotis{n_iter} - weights_check{n_iter}(1:end-6,:));
diff_speed = (weights_speed_robotis{n_iter} - weights_speed_check{n_iter});
diff_gyro = (weights_gyro_robotis{n_iter} - weights_gyro_check{n_iter});
