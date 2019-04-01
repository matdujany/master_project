clear; 
close all; clc;


%maybe i should try with both weights (LCs and robotis, but the orders of
%magnitudes are different ...)

addpath('clustering_functions');


%% Load data
addpath('../2_load_data_code');
recordID = 4;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis  = read_weights_pos_robotis(recordID,parms);

%% picking the weights to use
n_iter = 5;
weights_lc = weights_robotis{n_iter}(1:parms.n_lc*3,:);
weights_pos = weights_pos_robotis{n_iter};

%% plotting the hinton maps of the weights used
hinton_LC(weights_lc,parms);

%% fusing the weights for direction
%each row is 1 sensor, each column is 1 motor
%fusing the weights with the 2 directions
weights_fused = zeros(size(weights_lc,1),parms.n_m);
for i=1:parms.n_m
    weights_fused(:,i)= abs(weights_lc(:,1+2*(i-1))) + abs(weights_lc(:,2*i));
end

weights_fused_sumc = zeros(size(weights_fused,1)/3,parms.n_m);
for j=1:size(weights_fused,1)/3
    weights_fused_sumc(j,:)=abs(weights_fused(1+3*(j-1),:)) + abs(weights_fused(2+3*(j-1),:)) + abs(weights_fused(3*j,:));
end

weights_fused_sumc_norm = weights_fused_sumc./max(weights_fused_sumc,[],2);
weights_fused_sumc_norm2 = weights_fused_sumc./max(weights_fused_sumc,[],1);

%%
data_k_means = weights_fused_sumc';
data_k_means_standardized = standardize(data_k_means);

k_list = [1:parms.n_m]';
n_repeats = 10;

SSE = compute_elbow_curve(data_k_means_standardized,k_list,n_repeats);
mean_SSE = mean(SSE,2);
std_SSE = std(SSE,[],2);

[n_samples, n_dim] = size(data_k_means_standardized);
AIC  = mean_SSE + 2*k_list*n_dim;
BIC  = mean_SSE + log(n_samples)*k_list*n_dim;

%%
figure;
hold on;
errorbar(mean_SSE,std_SSE);
errorbar(AIC,std_SSE);
errorbar(BIC,std_SSE);
ylabel('Sum of squared distances');
xlabel('Number of clusters k');

