function hierarchical_clustering(weights,titleString)
%HIERARCHICAL_CLUSTERING Summary of this function goes here
%   Detailed explanation goes here
%distance matrix
dist_mat = squareform(pdist(weights)); %euclidian distance by default
%linkage methods : 'average', 'centroid', 'Ward'. See doc linkage for
%details.
linkage_method_list = {'single','complete', 'average', 'Ward'};
figure;
for i=1:length(linkage_method_list)
subplot(2,2,i);
Z = linkage(dist_mat,linkage_method_list{i});
dendrogram(Z);
title(linkage_method_list{i});
end
sgtitle(titleString);

end

