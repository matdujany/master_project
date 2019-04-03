clear; 
close all; clc;


%maybe i should try with both weights (LCs and robotis, but the orders of
%magnitudes are different ...)

addpath('clustering_functions');


%% Load data
addpath('../2_load_data_code');
recordID = 7;
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
weights = weights_fused_sumc_norm(3:4,:);
hinton(weights,'');

shift_txt = 0.05;
c=cellstr(num2str([1:12]'));
figure;
hold on;
scatter(weights(1,:),weights(2,:))
text(weights(1,:)+shift_txt,weights(2,:)+shift_txt,c);

