clear; 
close all; clc;

%a script to remove the first frames which were not used for learning
%(counting arduinos or timing the duration of the daisychain).
% the lpdata.i_part gives the actual number of frames used for learning and
% is used to check the number of lines to delete input by the user.

addpath('learning_functions');
addpath('../2_load_data_code');

recordID = 5;
filename = get_record_name(recordID);
[data, lpdata, parms] =  load_data_processed(recordID);

n_lines_delete = 1;

if (size(data.time,1)-length(lpdata.i_part)~=n_lines_delete)
    disp('Check the number of lines to delete');
    return;
end

%we remove the lines which corresponds to the frame counting arduino
data.time = data.time(1+n_lines_delete:end,:);
for i=1:length(data.float_value_time)
    if (size(data.float_value_time{1,i},1)-length(lpdata.i_part)~=n_lines_delete)
        disp('Pb with number of lines');
        return;
    end
    data.float_value_time{1,i} = data.float_value_time{1,i}(1+n_lines_delete:end,:);
end

%here we keep the first line (line of 0 added after differentiation to
%match the timelines)
%we delete n_lines after the first one.
for i=1:length(data.float_value_dot_time)
    if (size(data.float_value_dot_time{1,i},1)-length(lpdata.i_part)~=n_lines_delete)
        disp('Pb with number of lines');
        return;
    end    
    data.float_value_dot_time{1,i} = [data.float_value_dot_time{1,i}(1,:); data.float_value_dot_time{1,i}(2+n_lines_delete:end,:)];
end

file_name_processed_data=strcat("../../../../data/",filename,'_p');
fprintf("Writing processed data to file: %s.mat\n", file_name_processed_data);
save(file_name_processed_data,'data','lpdata','parms');