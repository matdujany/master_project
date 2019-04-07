clear; 
close all; clc;


%% Load data
addpath('../2_load_data_code');
recordID = 15;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
parms.n_useful_ch_IMU    = 6;
weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis  = read_weights_pos_robotis(recordID,parms);
parms_sim = parms;
parms_sim.eta = 10;
weights_sim = compute_weights_wrapper(data,lpdata,parms,1,0,0,0);

weights_chosen = weights_sim; %sim or robotis

%%
hinton_LC_2(weights_chosen{parms.n_twitches}',parms);

weights_lc_read=weights_chosen{parms.n_twitches}(1:parms.n_lc*3,:);

renorm_factor = max(max(abs(weights_lc_read)));
weights_lc = weights_lc_read/renorm_factor; 

%% fusing the weights for direction
%each row is 1 sensor, each column is 1 motor
%fusing the weights with the 2 directions
weights_fused = zeros(size(weights_lc,1),parms.n_m);
for i=1:parms.n_m
    weights_fused(:,i)= (abs(weights_lc(:,1+2*(i-1))) + abs(weights_lc(:,2*i)))/2;
end


%% fusing the weights over loadcell channels
weights_fused_sumc = zeros(parms.n_m,size(weights_fused,1)/3);
for j=1:size(weights_fused,1)/3
    weights_fused_sumc(:,j)=(abs(weights_fused(1+3*(j-1),:)) + abs(weights_fused(2+3*(j-1),:)) + abs(weights_fused(3*j,:)))/3;
end

weights_fused_zc = zeros(parms.n_m,size(weights_fused,1)/3);
for j=1:size(weights_fused,1)/3
    weights_fused_zc(:,j)=abs(weights_fused(3*j,:));
end

weights_fused_limbass = weights_fused_sumc;

%%
fontSize=18;
[h,fig_parms] = hinton_raw(weights_fused_limbass);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
for i=1:8
    text(x_min-0.1,i-0.5,['Motor ' num2str(9-i)],'FontSize',fontSize,'HorizontalAlignment','right');
end
for i=1:4
    text(i-0.5,y_max+0.1,['LC ' num2str(i)],'FontSize',fontSize,'HorizontalAlignment','center','VerticalAlignment','bottom');
end
h.Color = 'w';

for i_motor=1:8
    for i_lc=1:4
        text(i_lc-0.5,9-i_motor-0.5,num2str(weights_fused_limbass(i_motor,i_lc),'%.2f'),'FontSize',fontSize-2,'HorizontalAlignment','center');
    end
end
addpath('../../export_fig');
set(h,'Position',[10 10 600 900]);
set(h,'PaperOrientation','portrait');
%export_fig 'figures_simon/limb_assignment.pdf'
