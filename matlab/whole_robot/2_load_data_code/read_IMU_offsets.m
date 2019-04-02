function IMU_offsets = read_IMU_offsets(recordId,n_twitches)

IMU_offsets = zeros(n_twitches,6);

filename = get_record_name(recordId);
currentFolder = pwd;
cd('../../../../data');

fileID = fopen(strcat(filename,'.txt'));

for k=1:n_twitches
    tline = fgetl(fileID);
    while isempty(tline) ~strcmp(tline(1:3),'IMU')
        tline = fgetl(fileID);
    end
    A = textscan(fileID,FormatString,'delimiter','\n');
    weights_robotis{k}=zeros(n_lines,n_col);
    for j=1:n_col
        for i=1:n_lines
            weights_robotis{k}(i,j)=A{1,j}(i);
        end
    end
end

cd(currentFolder);