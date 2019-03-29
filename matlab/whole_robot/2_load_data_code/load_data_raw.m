function [data_rec, pos_load_data_rec, parms] = load_data_raw(recordID)
%LOAD_DATA Summary of this function goes here
%   Detailed explanation goes here
currentFolder = pwd;
cd('../../../../data');
filename = get_record_name(recordID);
load(filename,'data_rec','pos_load_data_rec','parms');
cd(currentFolder);
end

