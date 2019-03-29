clear; close all;

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
    n_ard = length(data.float_value_dot_time);
    n_frames = size(data.float_value_dot_time{1,1},1);
    for i_ard=1:n_ard
        data.float_value_dot_time{1,i_ard}=[zeros(1,3);data.float_value_dot_time{1,i_ard}];
    end
    save(processed_filenames_list{i},'data','lpdata','parms');
    clear data lpdata parms;
end
