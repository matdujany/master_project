clear;
close all; clc;

figure;
hold on;

subplot(2,1,1);
%punch_values = [32; 64; 128; 16; 8; 4];
punch_values = [4; 8; 16; 32 ; 64 ; 128];
legendCell = cellstr(num2str(punch_values, 'Punch = %-d'));
hold on;
for i=[6:-1:4 1:3]
    data_filename=strcat('data_motorparms_',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_load/10);
end
hold off;
xlabel('Time [s]');
ylabel('Motor Load [% of maximal torque]');
legend(legendCell);
subplot(2,1,2);
hold on;
for i=[6:-1:4 1:3]
    data_filename=strcat('data_motorparms_',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_position);
end
hold off;
legend(legendCell);
xlabel('Time [s]');
ylabel('Motor Position');


figure;
hold on;
subplot(2,1,1);
compliance_margin_values = [1; 5; 10; 25; 50];
legendCell = cellstr(num2str(compliance_margin_values, 'Compliance Margin = %-d'));
hold on;
for i=[1 7:10]
    data_filename=strcat('data_motorparms_',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_load/10);
end
hold off;
xlabel('Time [s]');
ylabel('Motor Load [% of maximal torque]');
legend(legendCell);
subplot(2,1,2);
hold on;
for i=[1 7:10]
    data_filename=strcat('data_motorparms_',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_position);
end
hold off;
legend(legendCell);
xlabel('Time [s]');
ylabel('Motor Position');

