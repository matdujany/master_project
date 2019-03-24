clear;
close all; clc;

%%
figure;
hold on;
subplot(2,1,1);
%punch_values = [32; 64; 128; 16; 8; 4];
compliance_margin_values = [1; 20 ;50];
legendCell = cellstr(num2str(compliance_margin_values, 'Compliance Margin = %-d'));
hold on;
for i=[1:3]
    data_filename=strcat('data_motorparms_dynamic_',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_load/10);
end
hold off;
xlabel('Time [s]');
ylabel('Motor Load [% of maximal torque]');
legend(legendCell);
subplot(2,1,2);
hold on;
for i=[1:3]
    data_filename=strcat('data_motorparms_dynamic_',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_position);
end
hold off;
legend(legendCell);
xlabel('Time [s]');
ylabel('Motor Position');

%%
figure;
hold on;
subplot(2,1,1);
punch_values = [4; 8; 16; 32; 64; 128];
legendCell = cellstr(num2str(punch_values, 'Punch = %-d'));
hold on;
for i=[8 7 6 1 4 5]
    data_filename=strcat('data_motorparms_dynamic_',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_load/10);
end
hold off;
xlabel('Time [s]');
ylabel('Motor Load [% of maximal torque]');
legend(legendCell);
subplot(2,1,2);
hold on;
for i=[8 7 6 1 4 5]
    data_filename=strcat('data_motorparms_dynamic_',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_position);
end
hold off;
legend(legendCell);
xlabel('Time [s]');
ylabel('Motor Position');

%% figure
hold on;
subplot(2,1,1);
freq_values = [1; 2 ;5];
legendCell = cellstr(num2str(freq_values, 'Frequency = %-d'));
hold on;
for i=[10 9 1]
    data_filename=strcat('data_motorparms_dynamic_',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_load/10);
end
hold off;
xlabel('Time [s]');
ylabel('Motor Load [% of maximal torque]');
legend(legendCell);
subplot(2,1,2);
hold on;
for i=[10 9 1]
    data_filename=strcat('data_motorparms_dynamic_',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_position);
end
hold off;
legend(legendCell);
xlabel('Time [s]');
ylabel('Motor Position');

