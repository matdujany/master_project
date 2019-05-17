
clear;
close all;

phi_cycle = linspace(0,4*pi+0.5,200);
phi_init = [pi/2; pi/2; pi/2; pi/2];
% phi_init = [0; 0; 0; 0];

% set_parms_locomotion;
params.amplitude_class2_deg = 20;
params.amplitude_class1_deg = 10;
params.alpha=1;
change_dir_class2 = 1;
change_dir_class1 = 0;
% change_dir_class2 = 0;
% change_dir_class1 = 1;
offset_class1 = pi/2;

shiftplot = 0.15;

x_patch_loading = [0 pi pi 0];
% x_patch_loading = pi/2+[0 pi pi 0];
amp_pos2 = params.amplitude_class2_deg * 3.413;
y_patch_loading = 1.2*[-amp_pos2 -amp_pos2 amp_pos2 amp_pos2]/512-shiftplot;
x_patch_stance = x_patch_loading+offset_class1;
amp_pos1 = params.amplitude_class1_deg * 3.413;
y_patch_stance = 2*[-amp_pos1 -amp_pos1 amp_pos1 amp_pos1]/512+shiftplot;

lineWidth = 1.2;
fontSize = 14;
fontSizeTicks = 14;

f=figure;
pos_class2 = phase2pos_wrapper(phi_init(1)+phi_cycle,1,change_dir_class2,params);
params.alpha=0.2;
pos_class2_alphadred = phase2pos_wrapper(phi_init(1)+phi_cycle,1,change_dir_class2,params);

pos_class1 = phase2pos_wrapper(phi_init(1)+phi_cycle+offset_class1,0,change_dir_class1,params);
hold on;
plot(phi_cycle,pos_class1/512-1+shiftplot,'r','LineWidth',lineWidth);
plot(phi_cycle,pos_class2/512-1-shiftplot,'b','LineWidth',lineWidth);
plot(phi_cycle,pos_class2_alphadred/512-1-shiftplot,'b--','LineWidth',lineWidth);
for i=0:1
    patch(i*2*pi+x_patch_loading,y_patch_loading,'b','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
    patch(i*2*pi+x_patch_stance,y_patch_stance,'r','FaceAlpha',0.1,'EdgeColor','none','HandleVisibility','off');
end
 lgd=legend({'Class 1, positive correlation between motor movement and robot speed in desired direction',...
     'Class 2, positive correlation between motor movement and load under limb','Class 2, with reduction of amplitude'},'FontSize',fontSize);
% lgd=legend({'Class 1, negative correlation between motor movement and robot speed in desired direction',...
%     'Class 2, negative correlation between motor movement and load under limb','Class 2, with reduction of amplitude'},'FontSize',fontSize);

ylabel('Motor Position','FontSize',fontSize);
xlabel('Limb Phase [rad]','FontSize',fontSize);
xticks([0:8]*pi/2);
xlim([0 4*pi+0.5]);
ylim(2*[-shiftplot shiftplot]);
set(gca,'xticklabels',{'0','\pi/2','\pi','3\pi/2','2\pi','5\pi/2','3\pi','7\pi/2','4\pi'});
yticks([-shiftplot, +shiftplot]);
set(gca,'yticklabels',{'Class 2 neutral position', 'Class 1 neutral position'});
set(gca,'YTickLabelRotation',90);
ax=gca();
ax.FontSize = fontSizeTicks;

f.Color = 'w';
f.Position = [596   390   985   588];
lgd.Position = [0.1379    0.8577    0.8142    0.1310];
set(f,'PaperOrientation','landscape');
% print(f, '-dpdf','-bestfit', 'figures_report/limb_oscillator_theory_pos_corr.pdf');
% print(f, '-dpdf','-bestfit', 'figures_report/limb_oscillator_theory_neg_corr.pdf');
