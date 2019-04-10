clear; 
close all; clc;


%here I assume that the limbs have been properly formed with
%limb_assignment, using the sum over all channels.

%% Load data
addpath('../2_load_data_code');
recordID = 27;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
parms.n_useful_ch_IMU    = 6;
weights_robotis  = read_weights_robotis(recordID,parms);
weights_pos_robotis  = read_weights_pos_robotis(recordID,parms);
parms_sim = parms;
parms_sim.eta = 10;
weights_sim = compute_weights_wrapper(data,lpdata,parms,1,0,0,0);

weights_chosen = weights_sim; %sim or robotis

%% showing weights used,correcting the sign
weights_lc_read=weights_chosen{parms.n_twitches}(1:parms.n_lc*3,:);

renorm_factor = max(max(abs(weights_lc_read)));
weights_lc = weights_lc_read/renorm_factor; 
weights_lc = weights_lc';

for i=1:parms.n_m*2
    weights_lc(i,:)=weights_lc(i,:)*(-1)^(i);
end

hinton_LC_2(weights_lc,parms,0);
hinton_IMU_2(weights_chosen{parms.n_twitches},parms);

%here I assume that the limbs have been properly formed with
%limb_assignment.
good_closest_LC = [3;3;4;4;1;1;2;2];
closest_LC = good_closest_LC;

limb=zeros(parms.n_lc,2);
for i=1:parms.n_lc
    limb(i,:) = find(closest_LC == i);
end

%% Manual weights where liftoff ?

%we see the lift off on record 17 but not on 15.
%M5+ lifts limb1
%M7- lifts limb2
%M1- lifts limb3
%M3+ lifts limb4
m_lift = [10 13 1 6];
for i=1:4
    %weights_lc(m_lift(i),:)=zeros(1,size(weights_lc,2));
    weights_lc(m_lift(i),3*i)=1;
end
hinton_LC_2(weights_lc,parms,1);


%%
n_limb = size(limb,1);
weights_limb_summedz = zeros(n_limb,parms.n_lc);
weights_limb_hip = zeros(n_limb,parms.n_lc,3);
weights_limb_knee = zeros(n_limb,parms.n_lc,3);
for i=1:n_limb
    for i_lc = 1:parms.n_lc
        index_m_neg = 1+2*(limb(i,1)-1);
        index_m_pos = 2*limb(i,1);
        index_m_neg2 = 1+2*(limb(i,2)-1);
        index_m_pos2 = 2*limb(i,2);
        index_list =[index_m_neg index_m_pos index_m_neg2 index_m_pos2];
        weights_limb_summedz(i,i_lc) = sum(weights_lc(index_list,3*i_lc))/4;        
        for channel=1:3
            weights_limb_hip(i,i_lc,channel) = sum(weights_lc([index_m_neg index_m_pos],3*(i_lc-1)+channel))/2;
            weights_limb_knee(i,i_lc,channel) = sum(weights_lc([index_m_neg2 index_m_pos2],3*(i_lc-1)+channel))/2;
        end
    end
end

%%
channel = 3;
channel_txt_list = {' X',' Y',' Z'};

limb_to_loadcell_effect_map(weights_limb_hip(:,:,channel),['Limb to Loadcell effect - Hip only - Channel ' channel_txt_list{1,channel}]);
limb_to_loadcell_effect_map(weights_limb_knee(:,:,channel),['Limb to Loadcell effect - Knee only - Channel ' channel_txt_list{1,channel}]);    
limb_to_loadcell_effect_map(0.5*(weights_limb_hip(:,:,channel)+weights_limb_knee(:,:,channel)),['Limb to Loadcell effect - Hip and Knee - Channel ' channel_txt_list{1,channel}]);

%%
inverse_map(weights_limb_hip(:,:,channel),['Inverse map - Hip only - Channel ' channel_txt_list{1,channel}])
inverse_map(weights_limb_knee(:,:,channel),['Inverse map - Knee only - Channel ' channel_txt_list{1,channel}]);    
inverse_map(0.5*(weights_limb_hip(:,:,channel)+weights_limb_knee(:,:,channel)),['Inverse map - Hip and Knee - Channel ' channel_txt_list{1,channel}]);

%%


limb_to_loadcell_effect_map(weights_limb_summedz,'Limb to Loadcell effect - Hip and Knee - Channel Z');
inverse_map(weights_limb_summedz,'Inverse map - Hip and Knee - Channel Z');


function h=limb_to_loadcell_effect_map(weights_limb,titleString)

[h,fig_parms] = hinton_raw(weights_limb);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;


fontSize = 14;
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
        value = weights_limb(i_limb,i_lc);
        if value>0
            color = 'k';
        else
            color = 'w';
        end
        text(i_lc-0.5,5-i_limb-0.5,num2str(value,'%.2f'),'Color',color,'FontSize',fontSize,'HorizontalAlignment','center');
    end
end
xlabel(titleString,'Color','k');
h.Color = 'w';
%set(h,'Position',[10 10 600 600]);
%set(h,'PaperOrientation','portrait');
end

function h=inverse_map(weights_limb,titleString)
% inverted map

inv_map_mat = inv(weights_limb);
[h,fig_parms] = hinton_raw(inv_map_mat);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

fontSize = 14;
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
        value = inv_map_mat(i_limb,i_lc);
        if value > 0
            text(i_lc-0.5,5-i_limb-0.5,num2str(value,'%.2f'),'FontSize',fontSize,'HorizontalAlignment','center');
        else
            text(i_lc-0.5,5-i_limb-0.5,num2str(value,'%.2f'),'FontSize',fontSize,'HorizontalAlignment','center','Color','w');
        end
    end
end
xlabel(titleString,'Color','k');
h.Color = 'w';
set(h,'Position',[700 10 600 600]);
set(h,'PaperOrientation','portrait');
end