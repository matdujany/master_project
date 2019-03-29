function [data, lpdata, parms] = load_data_processed(recordID)
%LOAD_DATA Summary of this function goes here
%   Detailed explanation goes here
currentFolder = pwd;
cd('../../../../data');
filename = strcat(get_record_name(recordID),'_p');
load(filename,'data','lpdata','parms');
cd(currentFolder);
end

