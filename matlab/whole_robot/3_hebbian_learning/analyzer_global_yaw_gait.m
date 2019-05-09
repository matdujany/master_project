clear; 
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 88;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
weights_robotis = read_weights_robotis(recordID,parms);


weights_gyro = weights_robotis{parms.n_twitches}(end-2:end,:);
weights_gyro = weights_gyro/max(max(abs(weights_gyro))) ;
% hinton_speed(weights_speed,parms,1);

weights_gyro_fused = fuse_weights_sym_direction(weights_gyro,parms);
% hinton_speed_fused(weights_speed_fused,parms,1);

%%
[limb,~,~] = get_good_limb(parms,recordID);
n_limb = size(limb,1);
weights_gyro_fused_limb_order = zeros(size(weights_gyro_fused));
for i=1:n_limb
    for j=1:2
        weights_gyro_fused_limb_order(:,j+2*(i-1))=weights_gyro_fused(:,limb(i,j));
    end
end

h_gyro = hinton_gyro_limb(weights_gyro_fused_limb_order,limb,1);

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
index_yaw_gyro = 3;
n_limb=size(limb,1);
motors_classes = zeros(n_limb,2); %class 1 are the movement effectors, class2 is the stance/swing effector
likelihood_class1 = zeros(n_limb,1);
dir_oscillations = ones(n_limb,2);
for i=1:n_limb
    limb_motor_list = limb(i,:);
    [values_c1, idx_c1 ] = maxk(abs(weights_gyro_fused_limb_order(index_yaw_gyro,limb_motor_list)),2);
    motors_classes(i,1) = limb_motor_list(idx_c1(1));
    likelihood_class1(i,1) = values_c1(1)/values_c1(2);
    limb_motor_list(idx_c1(1)) = [];
    [~, idx2 ] = max(abs(weights_lc_fused(3*i,limb_motor_list)));
    motors_classes(i,2) = limb_motor_list(idx2);
    
    if weights_gyro_fused_limb_order(index_yaw_gyro,motors_classes(i,1))<0
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
h_directmap = plot_limb_to_lc_effect(z_effect_limb_to_lc,parms,['Direct map for movement in yaw']);


%% inverse map for tegotae
z_effect_lc_to_limb = z_effect_limb_to_lc';
z_effect_lc_to_limb = z_effect_lc_to_limb/max(max(abs(z_effect_lc_to_limb))) ;

h_invmap = plot_lc_to_limb_inv_map(z_effect_lc_to_limb,parms,['Inverse map for movement in yaw']);

%% scaling sigma
frequency = 0.5;
total_load = 16;
GRF_term = mean(diag(z_effect_lc_to_limb))*total_load;
sigma_advanced = -0.5 * 2*pi*frequency/GRF_term;

%% for Robotis
disp('limbs array');disp(motors_classes - 1);
disp('changeDirs array '); disp(dir_oscillations == -1);
disp('sigma_advanced'); disp(sigma_advanced);
disp ('Inverse map :'); fprintf('{%.3f, %.3f, %.3f, %.3f} ,\n',z_effect_lc_to_limb');
