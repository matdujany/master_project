function rigid_body_pos = compute_rigid_body_pos(data_markers,data_quality,rigidbody_coordinates)
%COMPUTE_RIGID_BODY_POS Summary of this function goes here
%   Detailed explanation goes here

rigid_body_pos=zeros(size(data_markers,1),3);

for i_axis = 1:3
    offset = rigidbody_coordinates(1,i_axis+3*(0:5));
    rigid_body_pos(:,i_axis) = nansum( (data_markers(:,i_axis+3*(0:5))-offset)...
        .*data_quality(:,1:6) ,2)./nansum(data_quality,2);
end

end

