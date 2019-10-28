function rigid_body_pos = correct_weird_points(recordID,rigid_body_pos,data_markers,data_quality,rigidbody_coordinates)

weird_point_list = [];

switch recordID
    case 302
        weird_point_list = [1938; 5565];
    case 303
        weird_point_list = [8055; 10798];
end

for i=1:length(weird_point_list)
    index = weird_point_list(i);
    for i_axis = 1:3
        rigid_body_pos(index,:) = compute_rigid_body_pos(data_markers(index,:),...
        data_quality(index,:),rigidbody_coordinates);
    end   
end

end