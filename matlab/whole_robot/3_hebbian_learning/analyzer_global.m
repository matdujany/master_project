clear; 
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 89;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);


weights_speed_all = compute_weights_speed(data,lpdata,parms);
weights_speed = weights_speed_all{parms.n_twitches};
weights_speed = weights_speed/max(max(abs(weights_speed))) ;
% hinton_speed(weights_speed,parms,1);

weights_speed_fused = fuse_weights_sym_direction(weights_speed,parms);
% hinton_speed_fused(weights_speed_fused,parms,1);

%%
[limb,~,~] = get_good_limb(parms,recordID);
n_limb = size(limb,1);
weights_speed_fused_limb_order = zeros(size(weights_speed_fused));
for i=1:n_limb
    for j=1:2
        weights_speed_fused_limb_order(:,j+2*(i-1))=weights_speed_fused(:,limb(i,j));
    end
end

h_speed = hinton_speed_limb(weights_speed_fused_limb_order,limb,1);


%%
weights_robotis_last = weights_robotis{parms.n_twitches};
weights_lc = weights_robotis_last(1:3*parms.n_lc,:);
weights_lc = weights_lc/max(max(abs(weights_lc))) ;
% hinton_LC(weights_lc,parms,1);

weights_lc_fused = fuse_weights_sym_direction(weights_lc,parms);
% hinton_LC_fused(weights_lc_fused,parms,1);

[limb,~,~] = get_good_limb(parms,recordID);
n_limb = size(limb,1);
weights_lc_fused_limb_order = zeros(size(weights_lc_fused));
for i=1:n_limb
    for j=1:2
        weights_lc_fused_limb_order(:,j+2*(i-1))=weights_lc_fused(:,limb(i,j));
    end
end

% hinton_LC_limb(weights_lc_fused_limb_order,parms,limb,1);
h_lcz = hinton_LC_limb_1_channel(3,weights_lc_fused_limb_order,parms,limb,1);


%%
direction_list = {'X','Y','Z'};
desired_movement_speed_channel = 1;
n_limb=size(limb,1);
motors_classes = zeros(n_limb,2); %class 1 are the movement effectors, class2 is the stance/swing effector
likelihood_class1 = zeros(n_limb,1);
dir_oscillations = ones(n_limb,2);
for i=1:n_limb
    limb_motor_list = limb(i,:);
    [values_c1, idx_c1 ] = maxk(abs(weights_speed_fused(desired_movement_speed_channel,limb_motor_list)),2);
    motors_classes(i,1) = limb_motor_list(idx_c1(1));
    likelihood_class1(i,1) = values_c1(1)/values_c1(2);
    limb_motor_list(idx_c1(1)) = [];
    [~, idx2 ] = max(abs(weights_lc_fused(3*i,limb_motor_list)));
    motors_classes(i,2) = limb_motor_list(idx2);
    
    if weights_speed_fused(desired_movement_speed_channel,motors_classes(i,1))<0
        dir_oscillations(i,1)=-1;
    end 
    if weights_lc_fused(3*i,motors_classes(i,2))>0
        dir_oscillations(i,2)=-1;
    end
end

%% z effect
z_effect_limb_to_lc = zeros(parms.n_lc,n_limb);
for i_limb=1:n_limb
    for i_lc = 1:parms.n_lc      
%         z_effect_limb_to_lc(i_lc,i_limb) = sum(dir_oscillations(i_limb,1:2) .* weights_lc_fused(3*i_lc,motors_classes(i_limb,1:2)));
        z_effect_limb_to_lc(i_lc,i_limb) = dir_oscillations(i_limb,2) * weights_lc_fused(3*i_lc,motors_classes(i_limb,2));
    end
end
h_directmap = plot_limb_to_lc_effect(z_effect_limb_to_lc,parms,['Direct map for movement in direction ' direction_list{desired_movement_speed_channel}]);


%% inverse map for tegotae
z_effect_lc_to_limb = z_effect_limb_to_lc';
z_effect_lc_to_limb = z_effect_lc_to_limb/max(max(abs(z_effect_lc_to_limb))) ;

h_invmap = plot_lc_to_limb_inv_map(z_effect_lc_to_limb,parms,['Inverse map for movement in direction ' direction_list{desired_movement_speed_channel}]);

%% scaling sigma
frequency = 0.5;
total_load = 16;
GRF_term = mean(diag(z_effect_lc_to_limb))*total_load;
sigma_advanced = -0.5 * 2*pi*frequency/GRF_term;

%% for Robotis
disp('limbs array');disp(motors_classes - 1);
disp('changeDirs array '); disp(dir_oscillations == -1);
disp('sigma_advanced'); disp(sigma_advanced);
if parms.n_m == 8
    disp ('Inverse map :'); fprintf('{%.3f, %.3f, %.3f, %.3f} ,\n',z_effect_lc_to_limb');
else
    disp ('Inverse map :'); fprintf('{%.3f, %.3f, %.3f, %.3f, %.3f, %.3f} ,\n',z_effect_lc_to_limb');
end


%% exporting stuff
% addpath('../../export_fig');
% if false
%     export_fig('figures_simon_2/hinton_speed.pdf',h_speed);
%     export_fig('figures_simon_2/hinton_lcz.pdf',h_lcz);
%     export_fig('figures_simon_2/direct_map.pdf',h_directmap);
%     export_fig('figures_simon_2/inv_map_tegotae.pdf',h_invmap);
% end