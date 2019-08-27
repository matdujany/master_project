function [limb_list_ordered,limb_names_ordered] = get_limb_list_names(n_limb,recordID)
%GET_LIMB_LIST_NAMES Summary of this function goes here
%   Detailed explanation goes here
switch n_limb
    case 4
        limb_list_ordered = [3; 4; 2 ;1];
        limb_names_ordered= {'L1','L2','R1','R2'};
        if ismember(recordID,[70:104 115:120])
            limb_list_ordered = [2; 4; 1 ;3];
            limb_names_ordered= {'F','B','R','L'};
        end
    case 6
        limb_list_ordered = [4; 5; 6; 3; 2; 1];
        limb_names_ordered= {'L1','L2','L3','R1','R2','R3'};
    case 8
        limb_list_ordered = [5; 4; 3; 2; 6; 7; 8 ;1];
        limb_names_ordered= {'L1','L2','L3','L4','R1','R2','R3','R4'};
        if recordID >= 50
            limb_list_ordered = [5; 6; 7; 8; 4; 3; 2; 1];
        end
end
end

