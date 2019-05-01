%here i assume that the limbs have already been properly formed with limb
%assignment script.
% that the right directions for the hips have been determined with analyze
% z dropoff.
% that the right directions for the knees have been determined with analyze
% speed.


clear; 
close all; clc;


addpath('computing_functions');
addpath('hinton_plot_functions');

%% Load data
addpath('../2_load_data_code');
recordID = 75;
[data, lpdata, parms] =  load_data_processed(recordID);
parms = add_parms(parms);
% parms.n_useful_ch_IMU    = 6;
weights_robotis  = read_weights_robotis(recordID,parms);

[limb,sign_direction_dropoff,sign_direction_knee] = get_good_limb(parms,recordID);

%%
renorm_factor = max(max(abs(weights_robotis{parms.n_twitches})));
weights = 1*weights_robotis{parms.n_twitches}/renorm_factor;

hinton_LC(weights,parms,1);

%% fusing the weights over directions --> IS THIS THE PROPER WAY ?
n_limb = size(limb,1);
weights_hips_uncorrupted = zeros(3*parms.n_lc + parms.n_useful_ch_IMU,n_limb);
for i=1:n_limb
    if sign_direction_dropoff(i) == -1 
        %%%if -1 is the corrupted direction, then weight+ was the correct one
        weights_hips_uncorrupted(:,i) = weights(:,2*limb(i,1));
    end
    if sign_direction_dropoff(i) == 1 
        %%%if +1 is the corrupted direction, then weight- was the correct one
         weights_hips_uncorrupted(:,i) = weights(:,2*limb(i,1)-1);
    end
end

hinton_raw(weights_hips_uncorrupted);

%% z effect
z_effect_limb_to_lc = zeros(parms.n_lc,n_limb);
for i_limb=1:n_limb
    for i_lc = 1:parms.n_lc
%         z_effect_limb_to_lc(i_lc,i_limb) = sign_direction_dropoff(i_limb)*weights_fused_dir(3*i_lc,limb(i_limb,1)) + ...
%         sign_direction_knee(i_limb)*weights_fused_dir(3*i_lc,limb(i_limb,2));
        
%% just taking the hip effect for the moment, i flip the sign because it goes in the opposite direction as the uncorrupted
        z_effect_limb_to_lc(i_lc,i_limb) = -weights_hips_uncorrupted(3*i_lc,i_limb);
    end
end

plot_limb_to_lc_effect(z_effect_limb_to_lc,parms);
direct_map_symetrized = (z_effect_limb_to_lc+z_effect_limb_to_lc')/2;

plot_limb_to_lc_effect(direct_map_symetrized,parms);

%% inverse map
inv_map = inv(z_effect_limb_to_lc);
plot_lc_to_limb_inv_map(inv_map,parms);


inv_map2 = inv(direct_map_symetrized);
plot_lc_to_limb_inv_map(inv_map2,parms);

