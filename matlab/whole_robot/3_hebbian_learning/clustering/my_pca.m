function my_pca(data_pca,titleString)
n_samples_pca = size(data_pca,1);
data_pca_centered = data_pca- repmat(mean(data_pca),[n_samples_pca 1]);
[coeff, score, latent, tsquare,explained] = pca(data_pca_centered);
%coeff are the principal components, score are the coordinates of the data
%on the principal components
%warning : since i have less samples than variables (n_m<3*n_lc), the
%principal components are not unique.
explained3d = sum(explained(1:3));

shift_txt = 0.1;
c=cellstr(num2str([1:n_samples_pca]'));
figure;
hold on;
scatter3(score(:,1),score(:,2),score(:,3));
text(score(:,1)+shift_txt,score(:,2)+shift_txt,score(:,3)+shift_txt,c);
xlabel('1st Principal Component');
ylabel('2nd Principal Component');
zlabel('3rd Principal Component');
title(titleString);
end
