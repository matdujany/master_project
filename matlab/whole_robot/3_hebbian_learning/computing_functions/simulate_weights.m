function weights_sim = simulate_weights(data,lpdata,parms_sim,reps,flagPos,flagFilter,flagPlot,weights_init)
weights_sim = cell(parms_sim.n_twitches*reps,1);
for k=1:parms_sim.n_twitches
    weights_sim{k,1}=weights_init{k,1};
end    
for i=1:reps
    weights_init= weights_sim{parms_sim.n_twitches*i,1};
    if flagPos == 1
        weights_reiter=compute_weights_pos_wrapper(data,lpdata,parms_sim,flagFilter,flagPlot,weights_init);
    else    
        weights_reiter=compute_weights_wrapper(data,lpdata,parms_sim,flagFilter,flagPlot,0,0,weights_init);
    end
    for k=1:parms_sim.n_twitches
        weights_sim{k+i*parms_sim.n_twitches,1}=weights_reiter{k,1};
    end
end
end