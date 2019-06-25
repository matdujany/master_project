clear; 
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');
addpath('class_detection_function');

%% Load data
recordID = 110;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);



if recordID < 128
    weights_speed_all = compute_weights_speed(data,lpdata,parms);
else
    for k=1:parms.n_twitches
        weights_speed_all{k} = weights_robotis{k}(end-5:end-3,:);
    end
end

weights_speed = weights_speed_all{parms.n_twitches};
weights_speed = 100*weights_speed/max(max(abs(weights_speed)));
% hinton_speed(weights_speed,parms,1);


weights_speed_fused = fuse_weights_sym_direction(weights_speed,parms);
% hinton_speed_fused(weights_speed_fused,parms,1);

%%
if recordID == 90
    weights_speed_fused(1,2) = -0.18;
    disp('Warning, i have hardcoded M2 speed X effect to -0.18!');
end

if recordID == 94
    weights_speed_fused(1,[3 12 16]) = weights_speed_fused(1,[3 12 16])*5;
    disp('Warning, i have hardcoded M3 M12 and M16 speed X effect to *5!');
end  

if recordID == 111
    weights_speed_fused(1,[7 14]) = weights_speed_fused(1,[7 14])*5;
    disp('Warning, i have hardcoded M7 and M14 speed X effect to *5!');
end

%%
limb = get_good_limb(parms,recordID);
n_limb = size(limb,1);
weights_speed_fused_limb_order = zeros(size(weights_speed_fused));
for i=1:n_limb
    for j=1:2
        weights_speed_fused_limb_order(:,j+2*(i-1))=weights_speed_fused(:,limb(i,j));
    end
end

h_speed = hinton_speed_limb(weights_speed_fused_limb_order,limb,1);

%%

weights_yaw = weights_robotis{parms.n_twitches}(end,:);
weights_gyro = weights_robotis{parms.n_twitches}(end-2:end,:);
weights_yaw_rescaled = 100 * weights_yaw/max(max(abs(weights_gyro))) ;
weights_yaw_fused = fuse_weights_sym_direction(weights_yaw_rescaled,parms);
n_limb = size(limb,1);
weights_yaw_fused_limb_order = zeros(size(weights_yaw_fused));
for i=1:n_limb
    for j=1:2
        weights_yaw_fused_limb_order(:,j+2*(i-1))=weights_yaw_fused(:,limb(i,j));
    end
end

h_speed_yaw_limb = hinton_speed_yaw_limb(weights_speed_fused_limb_order,weights_yaw_fused_limb_order,limb,1);
h_speed_yaw_limb.Position = [126   178   970   600];


%%
% weights_check = compute_weights_wrapper(data,lpdata,parms,0,0,0,0);
% weights_check_last = weights_check{parms.n_twitches};
weights_robotis_last = weights_robotis{parms.n_twitches};

weights_lc = weights_robotis_last(1:3*parms.n_lc,:);
weights_lc = 100*weights_lc/max(max(abs(weights_lc))) ;
% hinton_LC(weights_lc,parms,1);

weights_lc_fused = fuse_weights_sym_direction(weights_lc,parms);
% hinton_LC_fused(weights_lc_fused,parms,1);

weights_lc_fused_limb_order = zeros(size(weights_lc_fused));
for i=1:n_limb
    for j=1:2
        weights_lc_fused_limb_order(:,j+2*(i-1))=weights_lc_fused(:,limb(i,j));
    end
end

% hinton_LC_limb(weights_lc_fused_limb_order,parms,limb,1);
h_lcz = hinton_LC_limb_1_channel(3,weights_lc_fused_limb_order,parms,limb,1);


%% class detection
desired_movement_speed_channel = 2; %1 for X, 2 for Y
direction_list = {'X','Y','Z'};
if recordID == 127
    [motors_classes,likelihood_class2,dir_oscillations,dir_oscillations_yaw] = get_class_c2_before_c1(desired_movement_speed_channel,limb,weights_speed_fused,weights_yaw_fused,weights_lc_fused);
else
    [motors_classes,likelihood_class1,dir_oscillations,dir_oscillations_yaw] = get_class_c1_before_c2(desired_movement_speed_channel,limb,weights_speed_fused,weights_yaw_fused,weights_lc_fused);
end
%% scaling amplitudes of class 1
weights_speed_class1 = zeros(n_limb,1);
weights_yaw_class1 = zeros(n_limb,1);
for i=1:n_limb
    weights_speed_class1(i) = weights_speed_fused(desired_movement_speed_channel,motors_classes(i,1));
    weights_yaw_class1(i) = weights_yaw_fused(1,motors_classes(i,1));
end
scaling_amp_class1_forward = abs(weights_speed_class1)/max(abs(weights_speed_class1));
scaling_amp_class1_yaw = abs(weights_yaw_class1)/max(abs(weights_yaw_class1));

%% z effect
z_effect_limb_to_lc = zeros(parms.n_lc,n_limb);
for i_limb=1:n_limb
    for i_lc = 1:parms.n_lc      
%          z_effect_limb_to_lc(i_lc,i_limb) = sum([-1 1].*dir_oscillations(i_limb,1:2) .* weights_lc_fused(3*i_lc,motors_classes(i_limb,1:2)));
        z_effect_limb_to_lc(i_lc,i_limb) = dir_oscillations(i_limb,2) * weights_lc_fused(3*i_lc,motors_classes(i_limb,2));
    end
end
% h_directmap = plot_limb_to_lc_effect(z_effect_limb_to_lc,parms,['Direct map for movement in direction ' direction_list{desired_movement_speed_channel}]);
 h_directmap = plot_limb_to_lc_effect(z_effect_limb_to_lc,parms);

%% inverse map for tegotae
z_effect_lc_to_limb = z_effect_limb_to_lc';
z_effect_lc_to_limb = z_effect_lc_to_limb/max(max(abs(z_effect_lc_to_limb))) ;

% h_invmap = plot_lc_to_limb_inv_map(z_effect_lc_to_limb,parms,['Inverse map for movement in direction ' direction_list{desired_movement_speed_channel}]);
h_invmap = plot_lc_to_limb_inv_map(z_effect_lc_to_limb,parms);

%% scaling sigma
frequency = 0.5;
switch parms.n_m
    case 8
        if recordID < 103
            total_load = 16;
        else 
            if recordID < 116
                total_load = 14; %cables removed
            else
                total_load = 12;%cables removed and weird configurations
            end
        end
     case 12
        if recordID < 107
            total_load = 22.5;
        else 
            total_load = 19.2; %cables removed
        end
    case 16
        if recordID < 111
            total_load = 29;
        else 
            total_load = 25.2; %cables removed
        end        
end
GRF_term = mean(diag(z_effect_lc_to_limb))*total_load;
sigma_advanced = -0.5 * 2*pi*frequency/GRF_term;

%% for Robotis
disp('limbs array');disp(motors_classes - 1);
disp('changeDirs array '); disp(dir_oscillations == -1);
disp('changeDirsYaw array '); disp(dir_oscillations_yaw == -1);

disp('sigma_advanced'); disp(sigma_advanced);
if parms.n_m == 8
    disp ('Inverse map :'); fprintf('{%.3f, %.3f, %.3f, %.3f} ,\n',z_effect_lc_to_limb');
    disp('Neutral pos :'); fprintf('{%i, %i, %i, %i, %i, %i, %i, %i} ,\n',read_neutral_pos(recordID, parms.n_m));
end
if parms.n_m == 12
    disp ('Inverse map :'); fprintf('{%.3f, %.3f, %.3f, %.3f, %.3f, %.3f} ,\n',z_effect_lc_to_limb');
end
if parms.n_m == 16
    disp ('Inverse map :'); fprintf('{%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f} ,\n',z_effect_lc_to_limb');
end



%% exporting stuff
addpath('../../export_fig');
if false
%     export_fig('figures_report/hinton_speed.pdf',h_speed);
%     export_fig('figures_simon_2/hinton_lcz.pdf',h_lcz);
%     export_fig(['figures_report/direct_map_' direction_list{desired_movement_speed_channel} '_' num2str(recordID) '.pdf'],h_directmap);
     export_fig(['figures_report/inv_map_' direction_list{desired_movement_speed_channel} '_' num2str(recordID) '.pdf'],h_invmap);
end

%%
disp ('scaling_amp_class1_forward :'); fprintf('%.2f\n',scaling_amp_class1_forward);

fprintf('%0.2f ', scaling_amp_class1_forward)
fprintf('%0.2f ', scaling_amp_class1_yaw)
