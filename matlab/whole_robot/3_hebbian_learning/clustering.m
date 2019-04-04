clear; 
close all; clc;


%maybe i should try with both weights (LCs and robotis, but the orders of
%magnitudes are different ...)

addpath('clustering_functions');


%% Load data
addpath('../2_load_data_code');
recordID = 15;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis  = read_weights_pos_robotis(recordID,parms);

%% simulating some weights to test filtering
flagFilter = 1;
parms_sim = parms;
parms_sim.eta = 5;
weights_sim = compute_weights_wrapper(data,lpdata,parms_sim,flagFilter,0,0,0);
weights_pos_sim = compute_weights_pos_wrapper(data,lpdata,parms_sim,flagFilter,0);

%% picking the weights to use
n_iter = 5;
weights_lc = weights_robotis{n_iter}(1:parms.n_lc*3,:);
weights_pos = weights_pos_robotis{n_iter};

%% plotting the hinton maps of the weights used
hinton_LC(weights_lc,parms);
hinton_pos(weights_pos,parms,1);

%% fusing the weights for direction
%each row is 1 sensor, each column is 1 motor
%fusing the weights with the 2 directions
weights_fused = zeros(size(weights_lc,1),parms.n_m);
for i=1:parms.n_m
    weights_fused(:,i)= abs(weights_lc(:,1+2*(i-1))) + abs(weights_lc(:,2*i));
end

weights_pos_fused = zeros(parms.n_m,parms.n_m);
for i=1:parms.n_m
    weights_pos_fused(:,i)= abs(weights_pos(:,1+2*(i-1))) + abs(weights_pos(:,2*i));
end

%% fusing the weights over loadcell channels
weights_fused_sumc = zeros(size(weights_fused,1)/3,parms.n_m);
for j=1:size(weights_fused,1)/3
    weights_fused_sumc(j,:)=abs(weights_fused(1+3*(j-1),:)) + abs(weights_fused(2+3*(j-1),:)) + abs(weights_fused(3*j,:));
end

hinton(weights_fused_sumc,'Loadcells');

weights_fused_sumc_norm = weights_fused_sumc./max(weights_fused_sumc,[],2);
weights_fused_sumc_norm2 = weights_fused_sumc./max(weights_fused_sumc,[],1);

hinton(weights_fused_sumc_norm,'Loadcells normalized');
%%
hierarchical_clustering(weights_fused_sumc_norm2','weights from LC');


%%
%we renorm because we want to use both weights and weights_pos in the same
%clustering but they have different order of magnitudes.
%each variable (that is to say each sensor)
weights_both_std=zeros(size(weights_lc,1)+parms.n_m,parms.n_m);
for i=1:size(weights_fused,1)
    weights_both_std(i,:)=standardize(weights_fused(i,:));
end
for i=1:parms.n_m
    weights_both_std(size(weights_fused,1)+i,:)=standardize(weights_pos_fused(i,:));
end

%%


%% clustering the motors with hierarchical clustering

hierarchical_clustering(weights_fused','weights from LC');
hierarchical_clustering(weights_pos_fused','weights from motor sensors');
hierarchical_clustering(weights_both_std','weights from LC and motor sensors, (standardized)');

% %% k means
% data_kmeans = weights_fused';
% idx_2clusters = kmeans(data_kmeans,2);
% idx_4clusters = kmeans(data_kmeans,4);


%% PCA for 3d reduction
%parms.n_lc*3 variables, parms.n_m observations;

% %maybe the data should be centered 
% my_pca(weights_fused','weights from LC');
% my_pca(weights_pos_fused','weights from motor sensors');
% my_pca(weights_both_std','weights from LC and motor sensors, (standardized)');
% 
% %% tSNE 
% my_tsne(weights_fused','weights from LC');
% my_tsne(weights_pos_fused','weights from motor sensors');
% my_tsne(weights_both_std','weights from LC and motor sensors, (standardized)');

%%
function  vector_standardized = standardize(vector)
mu = mean(vector);
vector_standardized = vector - mu;
stdev = std(vector_standardized);
vector_standardized = vector_standardized/stdev;
end

