clear; close all; clc;

load('pos_halfrobot_v2_2')
n_motors=size(motor_signals,1);

figure;
legend_list=cell(n_motors,1);
hold on;
for m=1:n_motors
    plot(time_ms/1000,motor_signals(m,:));
    legend_list{m}=strcat('M',num2str(m));
end
plot([1 time_ms(end)/1000],[512 512],'k--');
legend(legend_list);