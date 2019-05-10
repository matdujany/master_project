function h=hinton_LC_asymmetry(weights_lc,parms,writeValues)
 
weights_fused_asymmetry = zeros(size(weights_lc,1),parms.n_m);
for i=1:parms.n_m
    weights_fused_asymmetry(:,i) = (-weights_lc(:,2*i-1) + weights_lc(:,2*i))/2;
end
h = hinton_LC_fused(weights_fused_asymmetry,parms,writeValues);
xlabel('Dissymetry (+ direction - - direction)','FontSize',16);
end