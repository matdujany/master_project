function rgb = maxdistcolor_wrapper(n_colors)
%MAXDISTCOLOR_WRAPPER Summary of this function goes here
%   Detailed explanation goes here
addpath('../plotting_functions/maxdistcolor');
addpath('../plotting_functions/maxdistcolor/CIECAM02-master');
fun = @(m)srgb_2_Jab(m,'LCD');
rgb = maxdistcolor(n_colors,fun);
end

