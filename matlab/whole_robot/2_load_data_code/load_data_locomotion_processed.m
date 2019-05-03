function [data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID)
%LOAD_DATA Summary of this function goes here
%   Detailed explanation goes here
currentFolder = pwd;
cd('../../../../data/locomotion');
filename = strcat(get_record_name_locomotion(recordID),'_p');
load(filename,'data','pos_phi_data','parms_locomotion','parms');
cd(currentFolder);
end
