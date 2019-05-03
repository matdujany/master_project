function [lc_data, phi_position_data, parms_locomotion, parms] = load_data_locomotion(recordID)
%LOAD_DATA Summary of this function goes here
%   Detailed explanation goes here
currentFolder = pwd;
cd('../../../../data/locomotion/');
filename = get_record_name_locomotion(recordID);
load(filename,'lc_data','phi_position_data','parms_locomotion','parms');
cd(currentFolder);
end
