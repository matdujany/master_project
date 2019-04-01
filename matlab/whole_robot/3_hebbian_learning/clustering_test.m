close all
clear all
clc

%% Weight matrix and calculations
%weight matrices
w_ideal = [10, 3, 2, 1; 8, 5, 4, 3; 3, 10, 1, 2; 5, 8, 3, 4; 2, 1, 10, 3; 4, 3, 8, 5; 1, 2, 3, 10; 3, 4, 5, 8];
w = [10, 2.8, 2, 1.2; 8, 5, 4.2, 2.9; 3.1, 9.8, 1, 2.2; 5.1, 7.8, 3.2, 4.1; 1.9, 1.1, 10.1, 3.15; 4, 2.95, 7.9, 5.2; 0.9, 2.1, 3, 9.9; 2.85, 3.8, 4.8, 8.2];
w_hat = 1./w;

%linkage algorithm
Z = linkage(w,'single','euclidean')
Z_hat = linkage(w_hat,'single','euclidean'); %this doesn't work, don't quite understand why

%binning
[n_rows,n_columns] = size(w);
bins = zeros(n_rows,2);
bins(:,1) = [0; Z(:,3)];
bins(:,2) = [n_rows:-1:1]'

%bin change
bins_for_dot = [bins; [100, 0]]; %added so we can form a derivative
m = diff(bins_for_dot);
bin_dot = m(:,2)./m(:,1)

%inflection point of bin change (should be done mathematically with zeroing
%the second derivation; however since bins is monotonically decreasing,
%we can simply find the maximum in bin_dot and get the bin number
optimal_bins = 4;

%% Plots
figure(1)
[H,T]=dendrogram(Z,'Orientation','right');
title('dendrogram')
xlabel('distance')
ylabel('motor ID')

figure(2)
plot(bins_for_dot(:,1),bins_for_dot(:,2))
hold on
stairs(bins_for_dot(:,1),bins_for_dot(:,2))
xlim([min(Z(:,3)-1) max(Z(:,3)+1)])
ylim([0 n_rows+1])
title('distance vs. bins')
xlabel('distance')
ylabel('number of bins')

figure(3)
plot(bins(:,1),bin_dot)
hold on
stairs(bins(:,1),bin_dot)
plot(bins(:,1), m(:,2),'*')
title('change of bins vs. distance')
xlabel('distance')
ylabel('change of bins')

%% Other trials
% figure(3)
% dendrogram(Z_hat)

[a,b] = histc(Z(:,3),unique(Z(:,3)));
[c,d] = histcounts(Z(:,3),unique(Z(:,3)));
% y = a(b)