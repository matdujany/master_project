function functional_proximity_graph_fusedDir(weights,n_iter,index_ch_used,parms,titleString)
%FUNCTIONAL_PROXIMITY_GRAPH Summary of this function goes here
%   Detailed explanation goes here

proximity_motors = zeros(parms.n_m);
for m = 1:parms.n_m
    for m2 =1:parms.n_m
        
        proximity_motors(m,m2)=sum(sum(abs(...
            weights{n_iter}(index_ch_used,1+2*(m-1):2*m)-weights{n_iter}(index_ch_used,1+2*(m2-1):2*m2))));
    end
end

proximity_motors = proximity_motors+10*eye(parms.n_m); %otherwise the min operation of the next line returns the diag.
[~, motor_min]=min(proximity_motors,[],1);

proximity_matrix = zeros(parms.n_m);
for m = 1:parms.n_m
    proximity_matrix(m,motor_min(m))=1;
end

nodenames = {'1','2','3','4'};
G=digraph(proximity_matrix,nodenames);
figure;
plot(G);
title(titleString);

end

