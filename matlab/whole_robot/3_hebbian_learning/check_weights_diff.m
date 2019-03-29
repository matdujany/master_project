function max_dif_norm = check_weights_diff(weights_sim,weights_robotis,n_iter)


diff_weights = zeros(size(weights_robotis{1}));
diff_weights_norm = zeros(size(weights_robotis{1}));
for i = 1:size(diff_weights,1)
    for j = 1:size(diff_weights,2)
        diff_weights(i,j) = abs(weights_robotis{n_iter}(i,j)-weights_sim{n_iter}(i,j));
        diff_weights_norm(i,j) = 100*abs(weights_robotis{n_iter}(i,j)-weights_sim{n_iter}(i,j))/abs(weights_robotis{n_iter}(i,j));
    end
end

max_dif_norm = max(max(diff_weights_norm(weights_robotis{n_iter}>10^-3)));

format shortG
if max_dif_norm>0.1
    disp('There is a difference between the weights computed by Robotis and the simulated weights of more than 0.1 %');
    disp(['Diff value : ' num2str(max_dif_norm)]);
    %disp(diff_weights_norm*100);
end