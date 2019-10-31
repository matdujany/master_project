function distance_curve = compute_curve_distance(rigid_body_pos)
%CURVE_DISTANCE Summary of this function goes here
%   Detailed explanation goes here
distance_curve = sum(sqrt(sum(diff(rigid_body_pos).^2,2)));

end

