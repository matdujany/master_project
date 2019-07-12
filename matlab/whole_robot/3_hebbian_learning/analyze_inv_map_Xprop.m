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
recordID = 143;
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

hinton_LC(weights_robotis{parms.n_twitches},parms,1);

%% rescaling and fusing (LC part)

weights_lc = weights_robotis{parms.n_twitches}(1:3*parms.n_lc,:);
weights_lc = 100*weights_lc/max(max(abs(weights_lc))) ;
% hinton_LC(weights_lc,parms,1);

weights_lc_fused = fuse_weights_sym_direction(weights_lc,parms);
% hinton_LC_fused(weights_lc_fused,parms,1);
weights_lcz_fused = weights_lc_fused(3*[1:size(weights_lc_fused,1)/3],:);


%% rescaling and fusing (Speed part)
weights_speed = weights_speed_all{parms.n_twitches};
weights_speed = 100*weights_speed/max(max(abs(weights_speed)));
% hinton_speed(weights_speed,parms,1);

weights_speed_fused = fuse_weights_sym_direction(weights_speed,parms);
if recordID == 138
    msgbox('Warning, harcoding the speed X of M3 to -20');
    weights_speed_fused(1,3) = -20;
end

%% showing the initial data used
limb = get_good_limb(parms,recordID);
n_limb =size(limb,1);

% h_speed_yaw_limb.Position = [126   178   970   600];
% h_lcz = plot_hinton_lc_limb_order(weights_lc_fused,limb,parms);

motors_class_c2 = limb(:,1);
motors_class_c1 = limb(:,2);
dir_oscillations_c2 = get_dir_oscillations_c2(weights_lc_fused,motors_class_c2);
desired_movement_speed_channel = 1;

dir_oscillations_c1 = get_dir_oscillations_c1(desired_movement_speed_channel,weights_speed_fused,motors_class_c1);
 
%% z effect
z_effect_limb_to_lc = zeros(parms.n_lc,n_limb);
for i_limb=1:n_limb
    for i_lc = 1:parms.n_lc
        %          z_effect_limb_to_lc(i_lc,i_limb) = sum([-1 1].*dir_oscillations(i_limb,1:2) .* weights_lc_fused(3*i_lc,motors_classes(i_limb,1:2)));
        z_effect_limb_to_lc(i_lc,i_limb) = dir_oscillations_c2(i_limb) * weights_lc_fused(3*i_lc,motors_class_c2(i_limb));
    end
end
% h_directmap = plot_limb_to_lc_effect(z_effect_limb_to_lc,parms,['Direct map for movement in direction ' direction_list{desired_movement_speed_channel}]);
h_directmap = plot_limb_to_lc_effect(z_effect_limb_to_lc,parms);

%% inverse map for tegotae
z_effect_lc_to_limb = z_effect_limb_to_lc';
z_effect_lc_to_limb = z_effect_lc_to_limb/max(max(abs(z_effect_lc_to_limb))) ;

% h_invmap = plot_lc_to_limb_inv_map(z_effect_lc_to_limb,parms,['Inverse map for movement in direction ' direction_list{desired_movement_speed_channel}]);
h_invmap = plot_lc_to_limb_inv_map(z_effect_lc_to_limb,parms);

%% x effect
channel_selected = 2;
plot_hinton_lc_limb_order(weights_lc_fused,limb,parms,channel_selected);

x_effect_limb_to_lc = zeros(parms.n_lc,n_limb);
for i_limb=1:n_limb
    for i_lc = 1:parms.n_lc
        x_effect_limb_to_lc(i_lc,i_limb) = dir_oscillations_c1(i_limb) * weights_lc_fused(3*(i_lc-1)+channel_selected,motors_class_c1(i_limb));
    end
end
h_directmap_x = plot_limb_to_lc_effect(x_effect_limb_to_lc,parms,channel_selected);

%% inverse map for tegotae
x_effect_lc_to_limb = x_effect_limb_to_lc';
x_effect_lc_to_limb = x_effect_lc_to_limb/max(max(abs(x_effect_lc_to_limb))) ;

h_invmap_x = plot_lc_to_limb_inv_map(x_effect_lc_to_limb,parms);

%%
disp ('Inverse map :'); fprintf('{%.3f, %.3f, %.3f, %.3f, %.3f, %.3f} ,\n',x_effect_lc_to_limb');