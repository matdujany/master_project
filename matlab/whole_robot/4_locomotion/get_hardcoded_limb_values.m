function [limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(parms_locomotion,n_limb)
%GET_HARDCODED_LIMB_VALUES Summary of this function goes here
%   Detailed explanation goes here

switch n_limb
    case 4
        switch parms_locomotion.direction
            case 'X'
                limb_ids = [6 5; 8 7; 2 1; 4 3];
                changeDir = [0 0; 1 1; 1 1; 0 0];
            case 'Y'
                limb_ids = [5 6; 7 8; 1 2; 3 4]; %same as limbs but motor IDs are rescaled to 1:n_motors
                changeDir = [1 1; 1 0; 1 1; 1 0];
            case 'Yaw'
                limb_ids = [5 6; 7 8; 1 2; 3 4]; %same as limbs but motor IDs are rescaled to 1:n_motors
                changeDir = [1 1; 1 0; 0 1; 0 0];        
            otherwise
                disp('unrecognized locomotion direction');
        end

        real_servo_ids = [2     3    13    14    15    16    17    18];
        limbs = real_servo_ids(limb_ids);

        offset_class1 = [pi/2; pi/2; pi/2; pi/2];
        if isfield(parms_locomotion,'turning') && parms_locomotion.turning
           offset_class1 = [pi/2; -pi/2; -pi/2; pi/2];
        end
    case 8
         switch parms_locomotion.direction
            case 'X'
                limb_ids = 1+[0 8; 9 7; 4 3; 2 1; 13 12; 15 14; 11 10; 6 5];
                changeDir = [0 1; 1 0; 1 1; 1 1; 1 0; 0 1; 0 0; 0 0];
            otherwise
                disp('unrecognized locomotion direction');
         end
        
        real_servo_ids = [1:10  13:18];
        limbs = real_servo_ids(limb_ids);   
        offset_class1 = pi/2*ones(n_limb,1);
end

