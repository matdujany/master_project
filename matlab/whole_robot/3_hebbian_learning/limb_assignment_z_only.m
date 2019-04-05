clear; 
close all; clc;


%% Load data
addpath('../2_load_data_code');
recordID = 17;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
parms.n_useful_ch_IMU    = 6;
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
    %weights_fused(:,i)= abs(weights_lc(:,1+2*(i-1))) + abs(weights_lc(:,2*i));
    weights_fused(:,i)= weights_lc(:,1+2*(i-1)) + weights_lc(:,2*i);
end


%% fusing the weights over loadcell channels
weights_fused_sumc = zeros(parms.n_m,size(weights_fused,1)/3);
for j=1:size(weights_fused,1)/3
    %weights_fused_sumc(:,j)=abs(weights_fused(1+3*(j-1),:)) + abs(weights_fused(2+3*(j-1),:)) + abs(weights_fused(3*j,:));
    weights_fused_sumc(:,j) = abs(weights_fused(3*j,:));
end

%%
fontSize=18;
[h,fig_parms] = hinton_raw(weights_fused_sumc);
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
        text(i_lc-0.5,9-i_motor-0.5,num2str(weights_fused_sumc(i_motor,i_lc),'%.0f'),'FontSize',fontSize-2,'HorizontalAlignment','center');
    end
end
addpath('../../export_fig');
set(h,'Position',[10 10 1920-100 1080-100]);
set(h,'PaperOrientation','portrait');


%%
[~,closest_LC] = max(weights_fused_sumc,[],2);
good_closest_LC = [3;3;4;4;1;1;2;2];

if sum(abs(good_closest_LC-closest_LC))~=0
    disp('Problem with closest LCs found');
end

limb=zeros(parms.n_lc,2);
for i=1:parms.n_lc
    limb(i,:) = find(closest_LC == i);
end

%%
% n_limb = size(limb,1);
% weights_limb_z_dir = zeros(n_limb,parms.n_lc);
% for i=1:n_limb
%     for i_lc = 1:parms.n_lc
%         weights_limb_z_dir(i,i_lc) = weights_fused(3*i_lc,limb(i,1))+weights_fused(3*i_lc,limb(i,2));
%     end
% end
% 
% [h2,fig_parms] = hinton_raw(weights_limb_z_dir);
% x_min = fig_parms.xmin-0.2;
% x_max = fig_parms.xmax+0.2;
% y_min = fig_parms.ymin-0.2;
% y_max = fig_parms.ymax+0.2;
% 
% hold on;
% xlim([x_min, x_max]);
% ylim([y_min, y_max]);
% for i=1:4
%     text(x_min-0.1,i-0.5,['Limb ' num2str(5-i)],'FontSize',fontSize-2,'HorizontalAlignment','right');
% end
% for i=1:4
%     text(i-0.5,y_max+0.1,['LC ' num2str(i)],'FontSize',fontSize-2,'HorizontalAlignment','center','VerticalAlignment','bottom');
% end

%%
n_limb = size(limb,1);
weights_limb_summed = zeros(n_limb,parms.n_lc);
for i=1:n_limb
    for i_lc = 1:parms.n_lc
        weights_limb_summed(i,i_lc) = weights_fused_sumc(limb(i,1),i_lc)+weights_fused_sumc(limb(i,2),i_lc);
    end
end

[h2,fig_parms] = hinton_raw(weights_limb_summed);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
for i=1:4
    text(x_min-0.1,i-0.5,['Limb ' num2str(5-i)],'FontSize',fontSize,'HorizontalAlignment','right');
end
for i=1:4
    text(i-0.5,y_max+0.1,['LC ' num2str(i)],'FontSize',fontSize,'HorizontalAlignment','center','VerticalAlignment','bottom');
end
for i_limb=1:4
    for i_lc=1:4
        text(i_lc-0.5,5-i_limb-0.5,num2str(weights_limb_summed(i_limb,i_lc),'%.0f'),'FontSize',fontSize,'HorizontalAlignment','center');
    end
end
h2.Color = 'w';
set(h2,'Position',[10 10 1920-100 1080-100]);
set(h2,'PaperOrientation','portrait');

%% inverted map

inv_map_mat = inv(weights_limb_summed);
[h3,fig_parms3] = hinton_raw(inv_map_mat);
x_min = fig_parms3.xmin-0.2;
x_max = fig_parms3.xmax+0.2;
y_min = fig_parms3.ymin-0.2;
y_max = fig_parms3.ymax+0.2;

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
for i=1:4
    text(x_min-0.1,i-0.5,['LC ' num2str(5-i)],'FontSize',fontSize,'HorizontalAlignment','right');
end
for i=1:4
    text(i-0.5,y_max+0.1,['Limb ' num2str(i)],'FontSize',fontSize,'HorizontalAlignment','center','VerticalAlignment','bottom');
end
for i_limb=1:4
    for i_lc=1:4
        value = 10^4*inv_map_mat(i_limb,i_lc);
        if value > 0
            text(i_lc-0.5,5-i_limb-0.5,num2str(value,'%.0f'),'FontSize',fontSize,'HorizontalAlignment','center');
        else
            text(i_lc-0.5,5-i_limb-0.5,num2str(value,'%.0f'),'FontSize',fontSize,'HorizontalAlignment','center','Color','w');
        end
            
    end
end
h3.Color = 'w';
set(h3,'Position',[10 10 1920-100 1080-100]);
set(h3,'PaperOrientation','portrait');
