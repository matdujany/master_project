clear; 
close all; clc;

addpath('../2_load_data_code');
recordID = 27;
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
    weights_lc(m_lift(i),3*i)=1;
end
hinton_LC(weights_lc,parms,1);

%%
weights_speed = compute_weights_speed(data,lpdata,parms);
plot_weight_evolution_speed(weights_speed,parms);

hinton_speed(weights_speed{parms.n_twitches}',parms);

%%
%i assume here that the direction have been discovered with hinton speeds

%2 classes of motors : class1 is responsible for the stance/swing
% class 2 is responsible for making the movement in the direction we want.
%one of each class per limb
class1 = [1; 3; 5; 7];
class2 = [2; 4; 7; 8];

class1_motor_dirs = [1 2;2 1;2 1;1 2];
class2_motor_dirs = [2 1;1 2;1 2;2 1];

part_directions = [1 1;2 1;2 2;1 1];

i_limb = 1;
limb_effect_onz_phases = zeros(4,parms.n_lc);
for i_part=1:4
    idx_motor_c1 = class1_dirs(i_limb,part_directions(i_part,1))+2*(class1(i_part)-1);
    idx_motor_c2 = class2_dirs(i_limb,part_directions(i_part,2))+2*(class2(i_part)-1);
    for i_lc=1:parms.n_lc
        limb_effect_onz_phases(i_part,i_lc) = weights_lc(idx_motor_c1,3*i_lc) + weights_lc(idx_motor_c2,3*i_lc);
    end
end

%%
function h=limbphase_to_loadcell_effect_map(weights_limb,titleString)

[h,fig_parms] = hinton_raw(limb_effect_onz_phases);
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
end