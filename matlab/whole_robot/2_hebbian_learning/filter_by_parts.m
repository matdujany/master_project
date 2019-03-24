function signal_filtered = filter_by_parts(input_signal,i_part)
%UNTITLED3 Summary of this function goes here
%   typical input would be nb_samples x nb_channels
%   simple filter that should run fast on board, has to be causal, few
%   samples memory

if length(i_part) ~= size(input_signal,1)
    disp('the number of samples in input_signal and the length of i_part dont match');
    disp('returning 0');
    signal_filtered = 0;
    return;
end
start_index = 1;
current_index = 1;
while start_index<=length(i_part)
    while current_index<=length(i_part) && i_part(current_index) == i_part(start_index)
        current_index=current_index+1;
    end
    signal_filtered(start_index:current_index-1,:) = myfilter(input_signal(start_index:current_index-1,:));
    start_index=current_index;
end
end

