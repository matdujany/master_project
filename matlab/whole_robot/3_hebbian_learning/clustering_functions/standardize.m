function  data_standardized = standardize(data)
%data is n_samples x n_variables
%in output, each column has 0 mean and 1 stdev
[n_samples, n_variables] = size(data);
mu = mean(data,1);
data_centered = data - repmat(mu,n_samples,1);
stdev = std(data_centered,[],1);
data_standardized = data_centered./repmat(stdev,n_samples,1);
end
