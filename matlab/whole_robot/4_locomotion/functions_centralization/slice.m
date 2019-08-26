function signal_sliced = slice(signal,nb_strides,nb_sample_per_stride)
signal_sliced = zeros(nb_strides,nb_sample_per_stride);
for i=1:nb_strides
    signal_sliced(i,:) = signal(1+nb_sample_per_stride*(i-1):nb_sample_per_stride*i);
end
end