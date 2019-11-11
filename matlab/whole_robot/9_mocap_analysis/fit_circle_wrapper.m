function [speed_circle,circle_fit] = fit_circle_wrapper(traj_data,flagPlot)
%FIT_CIRCLE_WRAPPER Summary of this function goes here
%   source_data : Nx2 (2D data)
%   circle_fit = [a b R] is the fitting circle, center (a,b) and radius R
circle_fit = CircleFitByPratt(traj_data);

theta = [0:0.001:2*pi]';
radius_circle = circle_fit(3);
circle_points = [circle_fit(1)+radius_circle*cos(theta) circle_fit(2)+radius_circle*sin(theta)];
P = InterX(traj_data',circle_points');

if flagPlot
    figure;
    hold on;
%     plot(rigid_body_pos(frame_start:frame_stop,1),rigid_body_pos(frame_start:frame_stop,2));
    plot(traj_data(:,1),traj_data(:,2));
    plot(circle_points(:,1),circle_points(:,2));
    scatter(P(1,:),P(2,:));
    xlabel('X direction [m]');
    ylabel('Y direction [m]');
%     axis equal;
    xlim([min(traj_data(:,1)) max(traj_data(:,1))]);
    ylim([min(traj_data(:,2)) max(traj_data(:,2))]);
end

distance_circle = norm(P(:,end)-P(:,1));

[~,idx_1] = min((traj_data(:,1)-P(1,1)).^2 + (traj_data(:,2)-P(2,1)).^2);
[~,idx_2] = min((traj_data(:,1)-P(1,end)).^2 + (traj_data(:,2)-P(2,end)).^2);
time_circle = abs(idx_1-idx_2)*1/120;

speed_circle = distance_circle/time_circle;

end

