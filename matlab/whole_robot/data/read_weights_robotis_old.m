function weights_robotis = read_weights_robotis(recordId,parms)

filename = get_record_name(recordId);
n_col = parms.n_m*parms.n_dir;
n_lines =  parms.n_lc*parms.n_ch_lc + parms.n_useful_ch_IMU;
n_twitches = parms.n_twitches;

weights_robotis = cell(n_twitches,1);

fileID = fopen(strcat(filename,'.txt'));
FormatString_temp = repmat('%.5f',1,n_col); % cols.
FormatString = strcat(FormatString_temp,'; ... ');

A = textscan(fileID,FormatString,'HeaderLines',22,'delimiter','\n');

weights_robotis{1}=zeros(n_lines,n_col);
for j=1:n_col
    for i=1:n_lines
        weights_robotis{1}(i,j)=A{1,j}(i);
    end
end

for k=2:n_twitches
    B = textscan(fileID,FormatString,'HeaderLines',7,'delimiter','\n');
    weights_robotis{k}=zeros(n_lines,n_col);
    for j=1:n_col
        for i=1:n_lines
            weights_robotis{k}(i,j)=B{1,j}(i);
        end
    end
end
