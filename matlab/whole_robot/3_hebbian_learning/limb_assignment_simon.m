clear; 
close all; clc;


%% Load data
addpath('../2_load_data_code');
recordID = 15;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis  = read_weights_pos_robotis(recordID,parms);

%%
hinton_LC(weights_robotis{parms.n_twitches},parms);

weights_lc=weights_robotis{parms.n_twitches}(1:parms.n_lc*3,:);

%% fusing the weights for direction
%each row is 1 sensor, each column is 1 motor
%fusing the weights with the 2 directions
weights_fused = zeros(size(weights_lc,1),parms.n_m);
for i=1:parms.n_m
    weights_fused(:,i)= abs(weights_lc(:,1+2*(i-1))) + abs(weights_lc(:,2*i));
end


%% fusing the weights over loadcell channels
weights_fused_sumc = zeros(size(weights_fused,1)/3,parms.n_m);
for j=1:size(weights_fused,1)/3
    weights_fused_sumc(j,:)=abs(weights_fused(1+3*(j-1),:)) + abs(weights_fused(2+3*(j-1),:)) + abs(weights_fused(3*j,:));
end

%%
fontSize=14;
[h,fig_parms] = hinton_raw(weights_fused_sumc');
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
for i=1:8
    text(x_min-0.1,i-0.5,['Motor ' num2str(9-i)],'FontSize',fontSize-2,'HorizontalAlignment','right');
end
for i=1:4
    text(i-0.5,y_max+0.1,['LC ' num2str(i)],'FontSize',fontSize-2,'HorizontalAlignment','center','VerticalAlignment','bottom');
end
