function weights_fused = fuse_weights_without_corrupted_direction(weights_lc,parms)
[motor_ids_dropoff,sign_direction_dropoff]= get_hardcoded_dropoff_results(parms);
direction_slips = [-1  1 -1 1];
weights_fused = zeros(size(weights_lc,1),parms.n_m);
for i=1:parms.n_m
    idx = find(motor_ids_dropoff == i);
    if ~isempty(idx)
        direction_corrupted = sign_direction_dropoff(idx(1));
            
    else
        direction_corrupted = direction_slips(i/2);
    end
    switch direction_corrupted
        case 1
            weights_fused(:,i) = weights_lc(:,2*i-1);
        case -1
            weights_fused(:,i) = weights_lc(:,2*i);
    end
end
end