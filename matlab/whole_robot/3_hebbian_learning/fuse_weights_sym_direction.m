function weights_fused = fuse_weights_sym_direction(weights,parms)
weights_fused = zeros(size(weights,1),parms.n_m);
for i=1:parms.n_m
    weights_fused(:,i) = (weights(:,2*i-1) + weights(:,2*i))/2;
end
end