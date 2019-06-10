function neutral_pos = read_neutral_pos(recordId, n_m)
%READ_NEUTRAL_POS Summary of this function goes here
%   Detailed explanation goes here

if recordId < 100
    disp('Record ID < 100, neutral pos = 512');
    neutral_pos= 512*ones(n_m,1);
    return;
end

if ismember(recordId,[1051 1052]) %hand modified versions of map 105
    recordId = 105;
end
    
filename = get_record_name(recordId);
currentFolder = pwd;
cd('../../../../data');

fileID = fopen(strcat(filename,'.txt'));

tline = fgetl(fileID);
%disp(tline);
while size(tline)<24 | ~strcmp(tline(1:24),'Motor neutral positions:')
    tline = fgetl(fileID);
    %disp(tline);
end
if feof(fileID)
    disp('End of file reached - Returning');
    return;
end
neutral_pos_values_string = tline(25:end);
neutral_pos  = str2num(neutral_pos_values_string);


fclose(fileID);
cd(currentFolder);
end

