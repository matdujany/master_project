clear; 
close all; clc;

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 94;
% [data, lpdata, parms] =  load_data_processed(recordID);

z_effect_lc_to_limb = [
[-0.498, 0.107, 0.143, 0.018, -0.240, 0.041, 0.069, 0.462] ,
[0.172, -0.539, 0.425, -0.013, 0.086, -0.235, -0.036, 0.199] ,
[0.040, 0.561, -0.800, 0.215, 0.116, -0.129, 0.204, -0.082] ,
[-0.107, 0.067, 0.209, -0.352, 0.172, 0.058, 0.103, 0.031] ,
[-0.193, 0.089, 0.077, 0.100, -0.349, 0.165, 0.224, -0.061] ,
[0.155, -0.137, -0.164, 0.195, 0.179, -0.316, 0.219, -0.026] ,
[0.109, -0.129, 0.070, 0.050, 0.041, 0.341, -0.672, 0.232] ,
[0.539, 0.054, -0.068, 0.198, -0.133, 0.076, 0.336, -1.000]
 ];
 

parms.n_lc = 8;
h_invmap = plot_lc_to_limb_inv_map(z_effect_lc_to_limb,parms,'Inverse map');
addpath('../../export_fig');
export_fig('figures_simon_2/inv_map_tegotae_octopod.pdf',h_invmap);

