function latestfile = getlatestfile(directory)
%This function returns the latest file from the directory passsed as input
%argument

%Get the directory contents
dirc = dir(directory);

% Filter out all the folders.
tmp = {dirc.isdir};
dirc = dirc(find(~cellfun(@(x) x > 0, tmp)));

% Filter out all non-mat files
tmp = {dirc.name};
dirc = dirc(find(cellfun(@(x) strcmp(x(end-2:end), 'mat'), tmp)));
%Filter out all zip files.

%I contains the index to the biggest number which is the latest file
[~,I] = max([dirc(:).datenum]);

if ~isempty(I)
    latestfile = dirc(I).name;
end

end
