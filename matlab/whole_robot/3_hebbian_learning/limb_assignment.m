clear; 
close all; clc;


addpath('computing_functions');
addpath('hinton_plot_functions');

export_plots = false; 

%% Load data
addpath('../2_load_data_code');
recordID = 124;
[data, lpdata, parms] =  load_data_processed(recordID);
parms = add_parms(parms);
weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis  = read_weights_pos_robotis(recordID,parms);
parms_sim = parms;
parms_sim.eta = 20;
weights_sim = compute_weights_wrapper(data,lpdata,parms_sim,0,0,0,0);

weights_check = compute_weights_wrapper(data,lpdata,parms,0,0,0,0);
weights_chosen = weights_sim; %sim or robotis

%%
hinton_LC(weights_chosen{parms.n_twitches},parms,1);
hinton_LC_asymmetry(weights_chosen{parms.n_twitches},parms,1);

weights_lc_read=weights_chosen{parms.n_twitches}(1:parms.n_lc*3,:);

%%
renorm_factor = max(max(abs(weights_lc_read)));
weights_lc = 100*weights_lc_read/renorm_factor; 
hinton_LC(weights_lc,parms,1);

%% fusing the weights for direction
%each row is 1 sensor, each column is 1 motor
%fusing the weights with the 2 directions
weights_fused = zeros(size(weights_lc,1),parms.n_m);
for i=1:parms.n_m
    weights_fused(:,i) = ( weights_lc(:,2*i-1) + weights_lc(:,2*i) )/2;
end


%% fusing the weights over loadcell channels
weights_fused_norm = zeros(size(weights_fused,1)/3,parms.n_m);
for j=1:size(weights_fused,1)/3
    %weights_fused_sumc(j,:)=(abs(weights_fused(1+3*(j-1),:)) + abs(weights_fused(2+3*(j-1),:)) + abs(weights_fused(3*j,:)))/3;
    %weights_fused_sumc(j,:)=sum(abs(weights_fused([1:3]+3*(j-1),:)))/3;
    weights_fused_norm(j,:)=sqrt(sum( weights_fused([1:3]+3*(j-1),:).^2 ));
end

weights_fused_limbass = weights_fused_norm;
plot_weights_limb_assignment(weights_fused_limbass,parms);

%%
[~,closest_LC] = max(weights_fused_limbass,[],1);

likelihood_LC = zeros(1,parms.n_m);
for i=1:parms.n_m
    values = maxk(weights_fused_limbass(:,i),2);
    likelihood_LC(i) = values(1)/values(2);
end
format bank;
disp(likelihood_LC);
format;
disp(min(likelihood_LC));

%%
good_closest_LC = get_good_closest_LC(parms,recordID);

score_LC = sum(closest_LC' == good_closest_LC)
if sum(abs(good_closest_LC'-closest_LC))~=0
    disp('Problem with closest LCs found');
end

%%
h=plot_weights_limb_assignment(weights_fused_limbass,parms);
h.Colormap = [1 1 1; 1 0 0; 0 1 0; 1 1 0];%white, red, green, yellow
caxis('manual');
set(gca,'CLim',[1 4]);
patches = findobj(gca, 'type', 'patch');
patches.CData=ones(parms.n_m*parms.n_lc,1);
for i=1:parms.n_m
    if good_closest_LC(i) == closest_LC(i)
        patches.CData(parms.n_lc*i - closest_LC(i) +1) = 3;
    else
        patches.CData(parms.n_lc*i -  closest_LC(i) + 1) = 2;
        patches.CData(parms.n_lc*i -  good_closest_LC(i) + 1) = 4;
    end
end

if export_plots == true
    export_fig(['figures_report/limb_assignment_' num2str(recordID) '.pdf']);
end
%%

limb=zeros(parms.n_lc,2);
for i=1:parms.n_lc
    limb(i,:) = find(closest_LC == i);
end
        