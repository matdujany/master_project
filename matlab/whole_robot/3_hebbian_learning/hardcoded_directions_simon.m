clear; 
close all; clc;

addpath('../2_load_data_code');
recordID = 26;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;

good_closest_LC = [3;3;4;4;1;1;2;2];
limb=zeros(parms.n_lc,2);
for i=1:parms.n_lc
    limb(i,:) = find(good_closest_LC == i);
end

weights_robotis  = read_weights_robotis(recordID,parms);
weights_lc_read=weights_robotis{parms.n_twitches}(1:parms.n_lc*3,:);

renorm_factor = max(max(abs(weights_lc_read)));
weights_lc = weights_lc_read/renorm_factor; 
weights_lc = weights_lc;


% for i=1:parms.n_m*2
%     weights_lc(i,:)=weights_lc(i,:)*(-1)^(i);
% end
%hinton_LC_2(weights_lc,parms,0);

%% Manual weights where liftoff ?

%we see the lift off on record 17 but not on 15.
%M5+ lifts limb1
%M7- lifts limb2
%M1- lifts limb3
%M3+ lifts limb4
m_lift = [10 13 1 6];
for i=1:4
    %weights_lc(m_lift(i),:)=zeros(1,size(weights_lc,2));
    weights_lc(3*i,m_lift(i))=1;
end
%%
hinton_LC(weights_lc,parms,1);

%%
% weights_speed = compute_weights_speed(data,lpdata,parms);
% plot_weight_evolution_speed(weights_speed,parms);
% 
% hinton_speed(weights_speed{parms.n_twitches}',parms);

%%
for i=1:3*parms.n_lc
    for j=1:parms.n_m
        weights_fusedp(i,j) = (-weights_lc(i,1+2*(j-1)) + weights_lc(i,2*j))/2;
    end
end

%%
%i assume here that the direction have been discovered with hinton speeds

%2 classes of motors : class1 is responsible for the stance/swing
% class 2 is responsible for making the movement in the direction we want.
%one of each class per limb
class1 = [1; 3; 5; 7];
class2 = [2; 4; 6; 8];

class1_motor_dirs = [1 2 2 1];
class2_motor_dirs = [1 2 2 1];

n_limbs=size(limb,1);
limb_dirs = zeros(n_limbs,2);
for i=1:n_limbs
    idx_m1 = find(class1==limb(i,1));
    limb_dirs(i,1) = class1_motor_dirs(idx_m1);
    idx_m2 = find(class2==limb(i,2));
    limb_dirs(i,2) = class2_motor_dirs(idx_m2);
end

idx_motor_limb_effect = zeros(n_limbs,2);
for j = 1:n_limbs
  idx_motor_limb_effect(j,1) = 2*(limb(j,1)-1) + limb_dirs(j,1);
  idx_motor_limb_effect(j,2) = 2*(limb(j,2)-1) + limb_dirs(j,2);
end

limb_effect_sumz = zeros(parms.n_lc,n_limbs);
limb_effect_sumz2 = zeros(parms.n_lc,n_limbs);

for i_sensor = 1:parms.n_lc
    for j = 1:n_limbs
        limb_effect_sumz(i_sensor,j) = weights_lc(3*i_sensor,idx_motor_limb_effect(j,1))+weights_lc(3*i_sensor,idx_motor_limb_effect(j,2));
        limb_effect_sumz2(i_sensor,j) = (2*limb_dirs(j,1)-3)*weights_fusedp(3*i_sensor,limb(j,1))+...
            (2*limb_dirs(j,2)-3)*weights_fusedp(3*i_sensor,limb(j,2));
    end
end

%%
h=limb_to_loadcell_effect(limb_effect_sumz,1,'Method 1');
%method 1 : i take the corrupted direction and the required direction of the knee
h2=limb_to_loadcell_effect(limb_effect_sumz2,1,'Method 2');
%method 2 : i 'fuse' the two directions, and assign the signs

 
%h=limb_to_loadcell_effect(limb_effect_sumz,1,'');
addpath('../../export_fig');
set(h,'Position',[10 10 800 800]);
% export_fig 'figures_simon/limb_assignment_limbsummed.pdf'

%%
inv_map = inv(limb_effect_sumz);
h3 = plot_inv_map(inv_map,1);
set(h3,'Position',[10 10 1920-100 800]);
% export_fig 'figures_simon/limb_assignment_invmap.pdf'

function h=limb_to_loadcell_effect(limb_effect_sumz,writeValues,xlabelString)
[h,fig_parms] = hinton_raw(limb_effect_sumz);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
fontSize = 16;
for i=1:4
    text(x_min-0.1,i-0.5,['LC ' num2str(5-i)],'FontSize',fontSize-2,'HorizontalAlignment','right');
end
for i=1:4
    text(i-0.5,y_max+0.1,['Limb ' num2str(i)],'FontSize',fontSize-2,'HorizontalAlignment','center','VerticalAlignment','bottom');
end

if writeValues
    for i=1:4
        for j=1:4
            value = limb_effect_sumz(5-i,j);
            if value>0
                color = 'k';
            else
                color = 'w';
            end
            text(j-0.5,i-0.5,num2str(value,'%.2f'),'FontSize',fontSize-2,'HorizontalAlignment','center','Color',color);
        end
    end
end
h.Color = 'w';
xlabel(xlabelString);
end


function h=plot_inv_map(inv_map,writeValues)
[h,fig_parms] = hinton_raw(inv_map);
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;

hold on;
xlim([x_min, x_max]);
ylim([y_min, y_max]);
fontSize = 16;
for i=1:4
    text(x_min-0.1,i-0.5,['Limb ' num2str(5-i)],'FontSize',fontSize-2,'HorizontalAlignment','right');
end
for i=1:4
    text(i-0.5,y_max+0.1,['LC ' num2str(i)],'FontSize',fontSize-2,'HorizontalAlignment','center','VerticalAlignment','bottom');
end

if writeValues
    for i=1:4
        for j=1:4
            value = inv_map(5-i,j);
            if value>0
                color = 'k';
            else
                color = 'w';
            end
            text(j-0.5,i-0.5,num2str(value,'%.2f'),'FontSize',fontSize-2,'HorizontalAlignment','center','Color',color);
        end
    end
end
h.Color = 'w';

end