function [limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion)
%GET_HARDCODED_LIMB_VALUES Summary of this function goes here
%   Detailed explanation goes here


switch parms_locomotion.categoryName{1}(end)
    case 'X'
        limb_ids = [6 5; 8 7; 2 1; 4 3];
        changeDir = [0 0; 1 1; 1 1; 0 0];
    case 'Y'
        limb_ids = [5 6; 7 8; 1 2; 3 4]; %same as limbs but motor IDs are rescaled to 1:n_motors
        changeDir = [1 1; 1 0; 1 1; 1 0]; 
    otherwise
        disp('unrecognized locomotion direction');
end

real_servo_ids = [2     3    13    14    15    16    17    18];
limbs = real_servo_ids(limb_ids);

offset_class1 = [pi/2; pi/2; pi/2; pi/2];
if isfield(parms_locomotion,'turning') && parms_locomotion.turning
   offset_class1 = [pi/2; -pi/2; -pi/2; pi/2];
end

end

