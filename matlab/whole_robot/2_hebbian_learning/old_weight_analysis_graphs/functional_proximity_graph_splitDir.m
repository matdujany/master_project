function functional_proximity_graph_splitDir(weights,n_iter,index_ch_used,parms,titleString)
%FUNCTIONAL_PROXIMITY_GRAPH Summary of this function goes here
%   Detailed explanation goes here

proximity_motors = zeros(parms.n_m*2);
for m = 1:parms.n_m*2
    for m2 =1:parms.n_m*2
        proximity_motors(m,m2)=sum(abs(weights{n_iter}(index_ch_used,m)-weights{n_iter}(index_ch_used,m2)));
    end
end

proximity_motors = proximity_motors+10*eye(parms.n_m*2); %otherwise the min operation of the next line returns the diag.
[~, motor_min]=min(proximity_motors,[],1);

proximity_matrix = zeros(parms.n_m*2);
for m = 1:parms.n_m*2
    proximity_matrix(m,motor_min(m))=1;
end

nodenames = {'1-','1+','2-','2+','3-','3+','4-','4+'};
G=digraph(proximity_matrix,nodenames);
figure;
plot(G);
title(titleString);

end

