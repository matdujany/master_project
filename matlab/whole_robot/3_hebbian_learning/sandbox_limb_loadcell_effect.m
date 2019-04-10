close all;


addpath('../2_load_data_code');
recordID = 45;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
parms.n_useful_ch_IMU=4;

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

% my_matrix = [-0.3 0.3 0.8 -3.5; 2.4 5.9 -1.4 3.2; -2.7 -1.0 -0.7 -2.5; 3.0 -1.8 -0.3 4.5]/10;
% my_matrix_2 = [0 7.1 -2 -6.1; -0.9 0 3.6 1.1; 1.2 6.1 0 -10.8; 1.6 -8.8 8.6 0]/10;
% 
% 
% % limb_to_loadcell_effect(my_matrix,1,'1')
% % limb_to_loadcell_effect(my_matrix_2,1,'2')


for i=1:parms.n_m*2
    weights_lc_flipped(:,i)=weights_lc(:,i)*(-1)^(i);
end

% for i=1:parms.n_m
%     weights_lc_fused(:,i)=(weights_lc_flipped(:,2*i-1)+weights_lc_flipped(:,2*i))/2;
% end


% signs_motor_order = [-1 -1 1 1 1 1 -1 -1]; %in motor order (M1 ... M8)
% for i=1:parms.n_m*2
%     weights_lc_sign_corrected(:,i)=weights_lc_flipped(:,i)*signs_motor_order(ceil(i/2));
% end
% hinton_LC_zonly(weights_lc_sign_corrected,parms,1);

%%
hinton_LC(weights_lc_flipped,parms,1);
hinton_LC_zonly(weights_lc_flipped,parms,1);



%%
idx_m_methoda = [9 11; 14 16; 2 4; 5 7];%without the corrupted directions
idx_m_methodb = [10 12; 13 15; 1 3; 6 8];%with the corrupted directions

% for i=1:4
%     weights_lc_flipped(3*i,idx_m_methodb(i,1))=signs(i,1)*1;
% end

signs = [1 1; -1 -1; -1 -1; 1 1]; % in limb order (so M5 M6; M7 M8; M1 M2; M3 M4);

for i_sensor = 1:parms.n_lc
    for j = 1:4
        limb_effect_methoda(i_sensor,j) = sum(signs(j,:).*weights_lc_flipped(3*i_sensor,idx_m_methoda(j,:)));
        limb_effect_methodb(i_sensor,j) = sum(signs(j,:).*weights_lc_flipped(3*i_sensor,idx_m_methodb(j,:)));
    end
end

limb_to_loadcell_effect(limb_effect_methoda,1,'a');
limb_to_loadcell_effect(limb_effect_methodb,1,'b');

inv_mapa = inv(limb_effect_methoda);
plot_inv_map(inv_mapa,1);
inv_mapb = inv(limb_effect_methodb);
plot_inv_map(inv_mapb,1);

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