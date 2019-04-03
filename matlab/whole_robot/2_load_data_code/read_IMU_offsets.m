function IMU_offsets = read_IMU_offsets(recordId,n_twitches)

IMU_offsets = zeros(n_twitches,6);

filename = get_record_name(recordId);
currentFolder = pwd;
cd('../../../../data');

fileID = fopen(strcat(filename,'.txt'));

for k=1:n_twitches
    tline = fgetl(fileID);
    %disp(tline);
    while size(tline)<3 | ~strcmp(tline(1:3),'IMU')
        tline = fgetl(fileID);
        %disp(tline);
    end
    if feof(fileID)
        disp('End of file reached - Returning');
        return;
    end
    acc_values_string = tline(39:end);
    IMU_offsets(k,1:3)  = str2num(acc_values_string);
    tline = fgetl(fileID);
    gyro_values_string = tline(35:end);
    IMU_offsets(k,4:6)  = str2num(gyro_values_string);
end

fclose(fileID);
cd(currentFolder);