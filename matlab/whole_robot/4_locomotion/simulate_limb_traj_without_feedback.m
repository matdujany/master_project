
clear;
close all;

set_parms_locomotion;
phi_cycle = linspace(0,4*pi,200);
phi_init = [pi/2; pi/2; pi/2; pi/2];

[limbs,changeDir,offset_knee_to_hip] = get_hardcoded_limb_values();

figure;
for i_limb = 1:4
    subplot(2,2,i_limb)
    pos_hip = phase2pos_hipknee_wrapper(phi_init(i_limb)+phi_cycle,1,changeDir(i_limb,1),parms_locomotion);
    pos_knee = phase2pos_hipknee_wrapper(phi_init(i_limb)+phi_cycle+offset_knee_to_hip(i_limb),0,changeDir(i_limb,2),parms_locomotion);
    hold on;
    plot(phi_cycle,pos_hip,'b');
    plot(phi_cycle,pos_knee,'r');
    legend({['Hip, ID ' num2str(limbs(i_limb,1))],['Knee, ID ' num2str(limbs(i_limb,2))]});
    ylabel('Motor Position');
    xlabel('Phase Phi [rad]');
    title(['Limb ' num2str(i_limb)]);
end