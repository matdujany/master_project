function  SSE = compute_elbow_curve(data,k_list,n_repeats)
%data is n_samples x n_variables
%returns sum of squared error
n_samples = size(data,1);
SSE = zeros(length(k_list),n_repeats);

for index=1:length(k_list)
    k=k_list(index);
    for n=1:n_repeats
        [idx,C,sumd,D] = kmeans(data,k);
        error_part = 0;
        for i=1:n_samples
            error_part = error_part + norm(data(i,:)-C(idx(i),:))^2;
        end
        if abs(error_part - sum(sumd))>0.1
            disp(['Check error computation, something weird with k=' num2str(k)]);
        end
        SSE(index,n) = error_part;
    end
end
