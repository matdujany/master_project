function profile_spline = get_spline_profile(GRF_source,phi_source)
%GET_SPLINE_PROFILE Summary of this function goes here
%   Detailed explanation goes here
% GRF is n_points x 1

%% padding to make signal periodic
margin_pad = 0.5; %in radians
[~,idx1] = min(abs(phi_source-margin_pad));
phi_source = [phi_source; 2*pi + phi_source(1:idx1)];
GRF_source = [GRF_source; GRF_source(1:idx1)];
[~,idx2] = min(abs(phi_source-(2*pi-margin_pad)));
phi_source = [ - 2*pi + phi_source(idx2:end); phi_source];
GRF_source = [GRF_source(idx2:end); GRF_source];
[phi_source, index] = unique(phi_source); 
GRF_source = GRF_source(index);


%% we reduce the number of points by subsampling, using an average
%% otherwise spline and interpolation methods not successful there because too much points
grid_x = linspace(0-margin_pad,2*pi+margin_pad,100);
phi_grid = zeros(length(grid_x)-1,1);
GRF_grid = zeros(length(grid_x)-1,1);
for i=1:length(grid_x)-1
    idx = find(grid_x(i)<phi_source & phi_source<grid_x(i+1));
    phi_grid(i,1) = (grid_x(i) + grid_x(i+1))/2;
    GRF_grid(i,1) = mean(GRF_source(idx));
end

profile_spline = spline(phi_grid,GRF_grid);

end

