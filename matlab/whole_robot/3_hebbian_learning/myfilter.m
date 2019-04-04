% function signal_filtered = myfilter(input_signal)
% %UNTITLED4 Summary of this function goes here
% %   typical input would be nb_samples x nb_channels
% %   simple filter that should run fast on board, has to be causal, few
% %   samples memory
% 
% nb_samples = size(input_signal,1);
% nb_channels = size(input_signal,2);
% signal_filtered = zeros(nb_samples,nb_channels);
% for channel=1:nb_channels
%     signal_filtered(1,channel)=input_signal(1,channel);
%     for i=2:nb_samples
%         signal_filtered(i,channel) = 1/3*input_signal(i-1,channel)+2/3*input_signal(i,channel);
%     end
% end
% end
% 
% 

function signal_filtered = myfilter(input_signal,nb_moving_average)
%UNTITLED4 Summary of this function goes here
%   typical input would be nb_samples x nb_channels
%   simple filter that should run fast on board, has to be causal, few
%   samples memory
%   nb_moving_average is  nb of samples used to average --> 1 means no filtering
nb_samples = size(input_signal,1);
nb_channels = size(input_signal,2);
if nargin==1
    nb_moving_average = 5;
end
signal_filtered = zeros(nb_samples,nb_channels);
if nb_channels>nb_samples
    disp('Warning more channels than samples in the input signal to be filtered, transposing');
    signal_filtered_t = myfilter(input_signal',nb_moving_average);
    signal_filtered = signal_filtered_t';
    return;
end
for channel=1:nb_channels
    current_index=1;
    while current_index<nb_moving_average
        signal_filtered(current_index,channel) = mean(input_signal(1:current_index,channel));
        current_index = current_index+1;
    end
    while current_index<=nb_samples
        signal_filtered(current_index,channel) = ...
            mean(input_signal(current_index-nb_moving_average+1:current_index,channel));
        current_index = current_index+1;
    end
end
end



