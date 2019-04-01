function my_tsne(data_tsne,titleString)
n_samples = size(data_tsne,1);
Y = tsne(data_tsne);
shift_txt = 0.1;
c=cellstr(num2str([1:n_samples]'));
figure;
hold on;
scatter(Y(:,1),Y(:,2));
text(Y(:,1)+shift_txt,Y(:,2)+shift_txt,c);
title(strcat('t-SNE, ',titleString));

end
