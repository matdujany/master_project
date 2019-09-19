function [limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values(direction,n_limb,recordID)
%GET_HARDCODED_LIMB_VALUES Summary of this function goes here
%   for locomotion

switch n_limb
    case 4
        
        %starfish quadruped
        if ismember(recordID,[70:104 115:120])
            limb_ids = 1 + [0 2; 5 4; 3 1; 7 6];
            changeDir_C2 = [ 1; 0; 0; 1];
            switch direction
                case 'X'
                    changeDir_C1 = [0; 1; 1; 0];
                case 'Y'
                    changeDir_C1 = [0; 1; 0; 0];
                case 'Yaw'
                    changeDir_C1 = [1; 1; 1; 1];
                otherwise
                    disp('unrecognized locomotion direction');
            end
            changeDir = [changeDir_C1 changeDir_C2];
            real_servo_ids = [4:7    15:18];
        end
        
        %quadruped
        if ismember(recordID,[26:30 105:113  140:144])
            switch direction
                case 'X'
                    limb_ids = 1 + [5 4; 3 2; 1 0; 7 6];
                    changeDir = [0 0; 0 0; 1 1; 1 1];
                case 'Y'
                    limb_ids = 1 + [4 5; 2 3; 0 1; 6 7];
                    changeDir = [1  1; 1  0; 1  1; 1  0];
                otherwise
                    disp('unrecognized locomotion direction');
            end
            real_servo_ids = [4:7    15:18];
        end
        
    case 6
        %hexapod
        switch direction
            case 'X'
                limb_ids = 1+[9 8; 0 6; 4 3; 2 1; 7 5; 11 10];
                changeDir = [0 0; 0 1; 0 0; 1 1; 1 0; 1 1];
            otherwise
                disp('unrecognized locomotion direction');
        end
        real_servo_ids = [1 4:10  15:18];
    case 8
        %octopod        
        if recordID < 50
            switch direction
                case 'X'
                    limb_ids = 1+[0 8; 9 7; 4 3; 2 1; 13 12; 15 14; 11 10; 6 5];
                    changeDir = [0 1; 1 0; 1 1; 1 1; 1 0; 0 1; 0 0; 0 0];
                otherwise
                    disp('unrecognized locomotion direction');
            end
            real_servo_ids = [1:10  13:18];
        else
            switch direction
                case 'X'
                    limb_ids = 1+[13 12; 0 8; 6 5; 10 11; 2 1; 4 3; 9 7; 15 14];
                    changeDir = [0 0; 0 1; 0 0; 0 0; 1 1; 1 1; 1 0; 1 1];
                otherwise
                    disp('unrecognized locomotion direction');
            end
            real_servo_ids = [1:11  13 15:18];
        end
        
end

limbs = real_servo_ids(limb_ids);
offset_class1 = pi/2*ones(n_limb,1);
