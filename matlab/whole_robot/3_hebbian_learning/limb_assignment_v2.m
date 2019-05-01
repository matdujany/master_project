clear; 
close all; clc;

% here the dropoff are analyzed to remove the
% 'corrupted' hip weights.

addpath('computing_functions');
addpath('hinton_plot_functions');

%% Load data
addpath('../2_load_data_code');
recordID = 75;
[data, lpdata, parms] =  load_data_processed(recordID);
parms = add_parms(parms);
weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis  = read_weights_pos_robotis(recordID,parms);
parms_sim = parms;
parms_sim.eta = 10;
weights_sim = compute_weights_wrapper(data,lpdata,parms,1,0,0,0);

weights_chosen = weights_robotis; %sim or robotis

%%

weights_lc_read=weights_chosen{parms.n_twitches}(1:parms.n_lc*3,:);

renorm_factor = max(max(abs(weights_lc_read)));
weights_lc = 100*weights_lc_read/renorm_factor; 

hinton_LC(weights_lc,parms,1);

%%
threshold_factor = 0.1;
[totalcounts, min_dropoffs] = count_dropoffs(threshold_factor,data,parms,0);
dropoffs_summed = sum(totalcounts,3);
motor_ids_dropoff = zeros(parms.n_lc,1);
direction_dropoff = zeros(parms.n_lc,1);
for i=1:parms.n_lc
    [~, idx_raw] = max(dropoffs_summed(i,:));
    motor_ids_dropoff(i,1) = ceil(idx_raw/2);
    direction_dropoff(i,1) = -2*mod(idx_raw,2)+1;
end

%% fusing the weights for direction
%each row is 1 sensor, each column is 1 motor
%removing the corrupted directions for the hips
weights_fused = zeros(size(weights_lc,1),parms.n_m);
for i=1:parms.n_m
    idx = find(motor_ids_dropoff == i);
    if ~isempty(idx)
        direction_corrupted = direction_dropoff(idx(1));
        switch direction_corrupted
            case 1
                weights_fused(:,i) = -weights_lc(:,2*i-1);
            case -1
                weights_fused(:,i) = weights_lc(:,2*i);
        end              
    else
        weights_fused(:,i) = -weights_lc(:,2*i-1) + (weights_lc(:,2*i));
    end
end
hinton_LC_weights_fused(weights_fused,parms,1)
 
%% fusing the weights over loadcell channels
weights_fused_sumc = zeros(size(weights_fused,1)/3,parms.n_m);
for j=1:size(weights_fused,1)/3
    %weights_fused_sumc(j,:)=(abs(weights_fused(1+3*(j-1),:)) + abs(weights_fused(2+3*(j-1),:)) + abs(weights_fused(3*j,:)))/3;
    weights_fused_sumc(j,:)=sum(abs(weights_fused([1:3]+3*(j-1),:)),1);

end

weights_fused_limbass = weights_fused_sumc;
plot_weights_limb_assignment(weights_fused_limbass,parms);

%%
[~,closest_LC] = max(weights_fused_sumc,[],1);

likelihood_LC = zeros(1,parms.n_m);
for i=1:parms.n_m
    values = maxk(weights_fused_sumc(:,i),2);
    likelihood_LC(i) = values(1)/values(2);
end
format bank;
disp(likelihood_LC);
format;
disp(min(likelihood_LC));

%%
good_closest_LC = get_good_closest_LC(parms,recordID);

score_LC = sum(closest_LC' == good_closest_LC);
if sum(abs(good_closest_LC'-closest_LC))~=0
    disp('Problem with closest LCs found');
end