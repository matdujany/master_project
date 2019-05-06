function [limbs,limb_ids,changeDir,offset_knee_to_hip] = get_hardcoded_limb_values(parms_locomotion)
%GET_HARDCODED_LIMB_VALUES Summary of this function goes here
%   Detailed explanation goes here
limbs = [15 16; 17 18; 2 3; 13 14];
limb_ids = [5 6; 7 8; 1 2; 3 4]; %same as limbs but motor IDs are rescaled to 1:n_motors
changeDir = [0 0; 1 1; 1 1; 0 0];
offset_knee_to_hip = [pi/2; pi/2; pi/2; pi/2];
if isfield(parms_locomotion,'turning') && parms_locomotion.turning
   offset_knee_to_hip = [pi/2; -pi/2; -pi/2; pi/2];
end

end

