function parms_locomotion = add_parms_change_recordings(parms_locomotion,recordID)
%GET_PARMS_CHANGE_RECORDINGS Summary of this function goes here
%   Detailed explanation goes here

switch recordID
    case 22
        parms_locomotion.n_change = 3;
        parms_locomotion.time_change = [60, 90, 120];
        parms_locomotion.frequencies = [0.25, 0.5, 1, 1.5];
        parms_locomotion.sigma_advanced = [0.10, 0.19, 0.38, 0.57];
   case 26
        parms_locomotion.n_change = 2;
        parms_locomotion.time_change = [120, 180, 240];
        parms_locomotion.frequencies = [0.15, 0.5, 1];
        parms_locomotion.sigma_advanced = [0.0147,0.0490,0.0979];
end

end

