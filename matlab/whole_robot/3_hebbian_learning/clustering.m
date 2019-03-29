clear; 
close all; clc;


%% Load data
addpath('../2_load_data_code');
recordID = 4;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis  = read_weights_pos_robotis(recordID,parms);

%% simulating some weights to try out stuff
flagFilter = 1;
parms_sim = parms;
parms_sim.eta = 5;
weights_sim = compute_weights_wrapper(data,lpdata,parms_sim,flagFilter,0,0,0);

%% plotting the hinton maps
n_iter = 5;
hinton_LC(weights_robotis{n_iter},parms);
hinton_pos(weights_pos_robotis{n_iter},parms,1);

%% fusing the weights for direction
weights = weights_robotis{n_iter}(1:parms.n_lc*3,:);
%each row is 1 sensor, each column is 1 motor
%I use only the LC weights
%fusing the weights with the 2 directions
weights_fused = zeros(size(weights,1),parms.n_m);
for i=1:parms.n_m
    weights_fused(:,i)= abs(weights(:,1+2*(i-1))) + abs(weights(:,2*i));
end

%% clustering the motors with hierarchical clustering
%distance matrix
dist_mat = squareform(pdist(weights_fused')); %euclidian distance by default
%linkage methods : 'average', 'centroid', 'Ward'. See doc linkage for
%details.
linkage_method_list = {'single','complete', 'average', 'Ward'};
figure;
for i=1:length(linkage_method_list)
subplot(2,2,i);
Z = linkage(dist_mat,linkage_method_list{i});
dendrogram(Z);
title(linkage_method_list{i});
end

%% k means
data_kmeans = weights_fused';
idx_2clusters = kmeans(data_kmeans,2);
idx_4clusters = kmeans(data_kmeans,4);


%% PCA for 3d reduction
%parms.n_lc*3 variables, parms.n_m observations;

%maybe the data should be centered 
data_pca = weights_fused';
n_samples_pca = size(data_pca,1);
data_pca_centered = data_pca- repmat(mean(data_pca),[n_samples_pca 1]);
[coeff, score, latent, tsquare,explained] = pca(data_pca_centered);
%coeff are the principal components, score are the coordinates of the data
%on the principal components
%warning : since i have less samples than variables (n_m<3*n_lc), the
%principal components are not unique.
explained3d = sum(explained(1:3));

shift_txt = 0.1;
c=cellstr(num2str([1:n_samples_pca]'));
figure;
hold on;
scatter3(score(:,1),score(:,2),score(:,3));
text(score(:,1)+shift_txt,score(:,2)+shift_txt,score(:,3)+shift_txt,c);
