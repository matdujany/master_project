clear; close all;

gyro_gain =  0.06957;

files=dir(fullfile(cd,'*.mat'));

processed_filenames_list = {};
for i=1:length(files)
    filename = files(i).name;
    if strcmp(filename(end-5:end-4),'_p')
        processed_filenames_list{end+1} = filename;
    end
end

for i=1:length(processed_filenames_list)
    load(processed_filenames_list{i});
    if parms.IMU_offsets
        data_gyro = data.IMU_corrected(:,4:6);
        data_gyro_unitschanged = data_gyro*gyro_gain*pi/180;
        data.IMU_corrected(:,4:6) = data_gyro_unitschanged;
        save(processed_filenames_list{i},'data','lpdata','parms');
        
    end
    clear data lpdata parms;
end
