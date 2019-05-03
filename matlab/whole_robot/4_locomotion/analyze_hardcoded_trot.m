clear; close all; clc;
addpath('../2_load_data_code');

recordID = 4;
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

figure;
hold on;
for i=1:4
    plot((data.time(:,i)-data.time(1,i))/10^3,data.float_value_time{1,i}(:,3));
    legend_list{i} = ['LC ' num2str(i)];
end
legend(legend_list);
ylabel('Loadcell Z Channel [N]');
xlabel('Time [s]');


[limbs,limb_ids,~] = get_hardcoded_limb_values();

figure;
for i_limb = 1:4
    subplot(2,2,i_limb)
    hold on;
    plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,1),:)/10^3,pos_phi_data.motor_position(limb_ids(i_limb,1),:),'b');
    plot(pos_phi_data.motor_timestamps(limb_ids(i_limb,2),:)/10^3,pos_phi_data.motor_position(limb_ids(i_limb,2),:),'k');
    legend({['Hip, ID ' num2str(limbs(i_limb,1))],['Knee, ID ' num2str(limbs(i_limb,2))]});
    ylabel('Motor Position');
    xlabel('Time [s]');
    title(['Limb ' num2str(i_limb)]);
end
