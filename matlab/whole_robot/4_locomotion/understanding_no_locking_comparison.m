clear; close all; clc;
load('control_249');
load('control_250');

figure;
for i=1:6
    subplot(2,3,i);
    hold on;
    scatter(phi_249(:,i),feedback_249(:,i));
    scatter(phi_250(:,i),feedback_250(:,i));
    legend('249','250');
end
