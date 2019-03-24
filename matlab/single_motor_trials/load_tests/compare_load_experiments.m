clear;
close all; clc;

figure;
hold on;

subplot(2,1,1);
hold on;
for i=1:5
    data_filename=strcat('data',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_load/10);
end
hold off;
xlabel('Time [s]');
ylabel('Motor Load [% of maximal torque]');
subplot(2,1,2);
hold on;
for i=1:5
    data_filename=strcat('data',num2str(i));
    load(data_filename)
    plot(time_ms/1000,motor_position);
end
hold off;
xlabel('Time [s]');
ylabel('Motor Position');
