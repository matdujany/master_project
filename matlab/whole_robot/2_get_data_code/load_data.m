function [data, lpdata, parms] = load_data(recordID,boolProcessed)
%LOAD_DATA Summary of this function goes here
%   Detailed explanation goes here
currentFolder = pwd;
cd('../../../../data');
if boolProcessed
    filename = strcat(get_record_name(recordID),'_p');
else
    filename = get_record_name(recordID);
end
load(filename,'data','lpdata','parms');
cd(currentFolder);
end

