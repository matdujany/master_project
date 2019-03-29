function [G_fused, G_split] = functional_proximity_graph_both(weights,n_iter,index_ch_used,parms,titleString)
%FUNCTIONAL_PROXIMITY_GRAPH Summary of this function goes here
%   This plots a graph of functional proximity between motors.
%   By functional proximity, I mean that the connection weights from the
%   motors are compared. For each motor, the closest motor in terms of
%   functional proximity is the one with lowest absolute difference between
%   their connection weights to sensors (index_ch_used). In the fused part,
%   the motors have their direction fused and in the split part, each motor
%   is one direction only (one physical motor becomes 2 motors).

%%fused part
proximity_motors_fused = zeros(parms.n_m);
for m = 1:parms.n_m
    for m2 =1:parms.n_m
        
        proximity_motors_fused(m,m2)=sum(sum(abs(...
            weights{n_iter}(index_ch_used,1+2*(m-1):2*m)-weights{n_iter}(index_ch_used,1+2*(m2-1):2*m2))));
    end
end

proximity_motors_fused = proximity_motors_fused+100*eye(parms.n_m); %otherwise the min operation of the next line returns the diag.
[~, motor_min]=min(proximity_motors_fused,[],1);

proximity_matrix_fused = zeros(parms.n_m);
for m = 1:parms.n_m
    proximity_matrix_fused(m,motor_min(m))=1;
end

nodenames_fused = cell(parms.n_m,1);
for  m = 1:parms.n_m
    nodenames_fused{m}=['M' num2str(m)];
end
%nodenames_fused = {'M1','M2','M3','M4'};
G_fused=digraph(proximity_matrix_fused,nodenames_fused);

%%split part
proximity_motors_split = zeros(parms.n_m*2);
for m = 1:parms.n_m*2
    for m2 =1:parms.n_m*2
        proximity_motors_split(m,m2)=sum(abs(weights{n_iter}(index_ch_used,m)-weights{n_iter}(index_ch_used,m2)));
    end
end

proximity_motors_split = proximity_motors_split+100*eye(parms.n_m*2); %otherwise the min operation of the next line returns the diag.
[~, motor_min]=min(proximity_motors_split,[],1);

proximity_matrix_split = zeros(parms.n_m*2);
for m = 1:parms.n_m*2
    proximity_matrix_split(m,motor_min(m))=1;
end

nodenames = cell(2*parms.n_m,1);
for  m = 1:parms.n_m
    nodenames{1+2*(m-1)}=['M' num2str(m) '-'];
    nodenames{2*m}=['M' num2str(m) '+'];
end
G_split = digraph(proximity_matrix_split,nodenames);

%%plotting graph
figure;
subplot(1,2,1);
plot(G_fused);
title('Fused directions');
subplot(1,2,2);
plot(G_split);
title('Split directions');
%sgtitle(titleString);

end

