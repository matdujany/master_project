function weights_pos_robotis = read_weights_pos_robotis(recordId,parms)

n_col = parms.n_m*parms.n_dir;
n_lines =  parms.n_m;
n_twitches = parms.n_twitches;

weights_pos_robotis = cell(n_twitches,1);

filename = get_record_name(recordId);
fileID = fopen(strcat(filename,'.txt'));
FormatString_temp = repmat('%.5f',1,n_col); % cols.
FormatString = strcat(FormatString_temp,'; ... ');

for k=1:n_twitches
    tline = fgetl(fileID);
    while ~strcmp(tline,['weights_pos{' num2str(k) '} = [ ...'])
        tline = fgetl(fileID);
    end
    A = textscan(fileID,FormatString,'delimiter','\n');
    weights_pos_robotis{k}=zeros(n_lines,n_col);
    for j=1:n_col
        for i=1:n_lines
            weights_pos_robotis{k}(i,j)=A{1,j}(i);
        end
    end
end
