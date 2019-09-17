clear;
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');
addpath('class_detection_function');
addpath('analysis_plot_function');

%% Load data
recordID = 115;
[data, lpdata, parms] =  load_data_processed(recordID);
% [data, lpdata, parms] =  load_data_raw(recordID);

% parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);

if recordID < 128
    weights_speed_all = compute_weights_speed(data,lpdata,parms);
else
    for k=1:parms.n_twitches
        weights_speed_all{k} = weights_robotis{k}(end-5:end-3,:);
    end
end

%% rescaling and fusing
weights_speed = weights_speed_all{parms.n_twitches};
weights_speed = 100*weights_speed/max(max(abs(weights_speed)));
% hinton_speed(weights_speed,parms,1);

weights_speed_fused = fuse_weights_sym_direction(weights_speed,parms);
if recordID == 138
    msgbox('Warning, harcoding the speed X of M3 to -20');
    weights_speed_fused(1,3) = -20;
end
% hinton_speed_fused(weights_speed_fused,parms,1);

weights_yaw = weights_robotis{parms.n_twitches}(end,:);
weights_gyro = weights_robotis{parms.n_twitches}(end-2:end,:);
weights_yaw_rescaled = 100 * weights_yaw/max(max(abs(weights_gyro))) ;
weights_yaw_fused = fuse_weights_sym_direction(weights_yaw_rescaled,parms);

% weights_check = compute_weights_wrapper(data,lpdata,parms,0,0,0,0);
% weights_check_last = weights_check{parms.n_twitches};
weights_robotis_last = weights_robotis{parms.n_twitches};

weights_lc = weights_robotis_last(1:3*parms.n_lc,:);
weights_lc = 100*weights_lc/max(max(abs(weights_lc))) ;
% hinton_LC(weights_lc,parms,1);

weights_lc_fused = fuse_weights_sym_direction(weights_lc,parms);
% hinton_LC_fused(weights_lc_fused,parms,1);
weights_lcz_fused = weights_lc_fused(3*[1:size(weights_lc_fused,1)/3],:);


%% showing the initial data used
limb = get_good_limb(parms,recordID);
n_limb =size(limb,1);
% plot_hinton_speed_limb_order(weights_speed_fused,limb);

h_speed_yaw_limb = plot_hinton_speed_yaw_limb_order(weights_speed_fused,weights_yaw_fused,limb);
% h_speed_yaw_limb.Position = [126   178   970   600];
h_lcz = plot_hinton_lc_limb_order(weights_lc_fused,limb,parms);

%%
% close all;
% h_lcz = plot_hinton_lc_limb_order(weights_lc_fused,limb,parms);
% h_lcz = plot_hinton_lc_limb_order_renorm_column(weights_lc_fused,limb,parms)

% [h_lcz, weights_lcz_fused_limb_order_ratios] = plot_hinton_lc_limb_order_ratio_column(weights_lc_fused,limb,parms);
% motors_class_c2 = get_class_c2_maximize_deltas(limb,weights_lcz_fused);
% inv_map_max_deltas = get_inverse_map(weights_lc_fused,motors_class_c2,parms);
% h_invmap = plot_lc_to_limb_inv_map(inv_map_max_deltas,parms);
%

%% class detection
desired_movement_speed_channel = 1; %1 for X, 2 for Y
direction_list = {'X','Y','Z'};

%c1 first
if ismember(recordID,[105 110 115 138:140])
         [motors_classes,likelihood_class1,dir_oscillations,dir_oscillations_yaw] = get_class_c1_before_c2(desired_movement_speed_channel,limb,weights_speed_fused,weights_yaw_fused,weights_lc_fused);
end
% c2 first
if ismember(recordID,[127 143 200:204 210 220])
        [motors_classes,likelihood_class2,dir_oscillations,dir_oscillations_yaw] = get_class_c2_before_c1(desired_movement_speed_channel,limb,weights_speed_fused,weights_yaw_fused,weights_lc_fused);
end
if ismember(recordID,[134:137])
        [motors_classes,dir_oscillations,dir_oscillations_yaw,likelihood_class2] = get_class_c2_maximize_deltas_wrapper(desired_movement_speed_channel,limb,weights_speed_fused,weights_yaw_fused,weights_lc_fused);
        % motors_class_c2 = get_class_c2_maximize_deltas(limb,weights_lcz_fused);
end
if ismember(recordID,[144])
    motors_classes = [limb(:,2) limb(:,1)];
    [dir_oscillations,dir_oscillations_yaw] = get_dir_oscillations(desired_movement_speed_channel,motors_classes,weights_lc_fused,weights_speed_fused,weights_yaw_fused);
end

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


%% scaling amplitudes of class 1
weights_speed_class1 = zeros(n_limb,1);
weights_yaw_class1 = zeros(n_limb,1);
for i=1:n_limb
    weights_speed_class1(i) = weights_speed_fused(desired_movement_speed_channel,motors_classes(i,1));
    weights_yaw_class1(i) = weights_yaw_fused(1,motors_classes(i,1));
end
scaling_amp_class1_forward = abs(weights_speed_class1)/max(abs(weights_speed_class1));
scaling_amp_class1_yaw = abs(weights_yaw_class1)/max(abs(weights_yaw_class1));


%% scaling sigma
frequency = 0.5;
total_load = get_total_load(recordID,parms.n_m);

GRF_term = mean(diag(z_effect_lc_to_limb))*total_load;
sigma_advanced = -0.5 * 2*pi*frequency/GRF_term;

%% for Robotis
disp('limbs array'); fprintf('{%i, %i},\n',motors_classes'-1);
fprintf('\n');

LogicalStr = {'false', 'true'};
disp('changeDirs array '); fprintf('{%s,%s},\n',LogicalStr{(dir_oscillations'==-1) + 1});
fprintf('\n');
disp('changeDirsYaw array '); fprintf('%s,',LogicalStr{(dir_oscillations_yaw'==-1) + 1});
fprintf('\n \n');

disp('sigma_advanced :'); fprintf('%.4f\n',sigma_advanced);
fprintf('\n');

if parms.n_m == 8
    disp ('Inverse map :'); fprintf('{%.3f, %.3f, %.3f, %.3f} ,\n',z_effect_lc_to_limb');
    fprintf('\n');
    disp('Neutral pos :'); fprintf('{%i, %i, %i, %i, %i, %i, %i, %i} ;\n',read_neutral_pos(recordID, parms.n_m));
end
if parms.n_m == 12
    disp ('Inverse map :'); fprintf('{%.3f, %.3f, %.3f, %.3f, %.3f, %.3f} ,\n',z_effect_lc_to_limb');
    fprintf('\n');
    disp('Neutral pos :'); fprintf('{%i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i} ;\n',read_neutral_pos(recordID, parms.n_m));
end
if parms.n_m == 16
    disp ('Inverse map :'); fprintf('{%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f} ,\n',z_effect_lc_to_limb');
    fprintf('\n');
    disp('Neutral pos :'); fprintf('{%i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i} ;\n',read_neutral_pos(recordID, parms.n_m));
end

disp ('scaling_amp_class1_forward :');
fprintf('%.3f,',scaling_amp_class1_forward);
fprintf('\n \n')

disp ('scaling_amp_class1_yaw :');
fprintf('%.3f,',scaling_amp_class1_yaw);
fprintf('\n \n');



%% exporting stuff
addpath('../../export_fig');
if false
    %     export_fig('figures_report/hinton_speed.pdf',h_speed);
    %     export_fig('figures_simon_2/hinton_lcz.pdf',h_lcz);
    %     export_fig(['figures_report/direct_map_' direction_list{desired_movement_speed_channel} '_' num2str(recordID) '.pdf'],h_directmap);
    export_fig(['figures_report/inv_map_' direction_list{desired_movement_speed_channel} '_' num2str(recordID) '.pdf'],h_invmap);
end
