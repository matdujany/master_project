clear; close all; clc;

n_points = 100;
noise_level = 0.1;
t=linspace(0,10,n_points)';
x = 3+t+0.1*t.^2;
y1 = -2 - 0.5*t -0.1*t.^2 + noise_level*randn(n_points,1);
y2 =  1 + 0.1*t + 0.2*t.^2 + noise_level*randn(n_points,1);

size_mv_average = 5;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
x_diff = filter(filter_coeffs,1,diff(x)); %causal
y1_diff = filter(filter_coeffs,1,diff(y1)); %causal
y2_diff = filter(filter_coeffs,1,diff(y2)); %causal

x_sum = cumsum(x);
y1_sum = cumsum(y1);
y2_sum = cumsum(y2);

figure;
subplot(1,3,1);
hold on;
plot(t,x_sum,'k');
plot(t,y1_sum,'r');
plot(t,y2_sum,'b');
subplot(1,3,2);
hold on;
plot(t,x,'k');
plot(t,y1,'r');
plot(t,y2,'b');
subplot(1,3,3);
hold on;
plot(x_diff,'k');
plot(y1_diff,'r');
plot(y2_diff,'b');

corr(x,y1)
corr(x,y2)

learning_rate = 10^-6;
[~,w_detailed_int_1] = hebbian_learning(x_sum,y1_sum,learning_rate);
[~,w_detailed_int_2] = hebbian_learning(x_sum,y2_sum,learning_rate);


learning_rate = 0.001;
[~,w_detailed_1] = hebbian_learning(x,y1,learning_rate);
[~,w_detailed_2] = hebbian_learning(x,y2,learning_rate);

learning_rate = 10;
[~,w_detailed_diff_1] = hebbian_learning(x_diff,y1_diff,learning_rate);
[~,w_detailed_diff_2] = hebbian_learning(x_diff,y2_diff,learning_rate);

figure;
subplot(1,3,1);
hold on;
plot(w_detailed_int_1,'r');
plot(w_detailed_int_2,'b');
subplot(1,3,2);
hold on;
plot(w_detailed_1,'r');
plot(w_detailed_2,'b');
subplot(1,3,3);
hold on;
plot(w_detailed_diff_1,'r');
plot(w_detailed_diff_2,'b');

mean(x.*y1)/mean(x.^2)
mean(diff(x).*diff(y1))/mean(diff(x).^2)

function [w_final,w_detailed] = hebbian_learning(x,y,learning_rate)
w_detailed = zeros(length(x)+1,1);
for i=1:length(x)
    r = x(i,1)*y(i,1) - x(i,1) * x(i,1) * w_detailed(i,1);
    w_detailed(i+1,1) = learning_rate*r +  w_detailed(i,1);
end
w_final = w_detailed(end,1);
end