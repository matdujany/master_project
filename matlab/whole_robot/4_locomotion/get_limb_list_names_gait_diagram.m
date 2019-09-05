function [limb_list_gait_diagram,limb_names_gait_diagram] = get_limb_list_names_gait_diagram(n_limb,recordID)
%GET_LIMB_LIST_NAMES_GAIT_DIAGRAM Summary of this function goes recordID
%   Detailed explanation goes here

switch n_limb
    case 4
        limb_list_gait_diagram = [2; 1; 3 ;4];
        limb_names_gait_diagram= {'R1','R2','L1','L2'};
        if ismember(recordID,[70:104 115:120])
            limb_list_gait_diagram = [2; 1; 3 ;4];
            limb_names_gait_diagram= {'F','R','L','B'};
        end
    case 6
        limb_list_gait_diagram = [3; 2; 1; 4; 5; 6];
        limb_names_gait_diagram= {'R1','R2','R3','L1','L2','L3'};
    case 8
        limb_list_gait_diagram = [6; 7; 8; 1; 5; 4; 3; 2];
        limb_names_gait_diagram = {'R1','R2','R3','R4','L1','L2','L3','L4'};
        if recordID >= 50
            limb_list_gait_diagram = [4; 3; 2; 1; 5; 6; 7; 8];
        end
end

end

