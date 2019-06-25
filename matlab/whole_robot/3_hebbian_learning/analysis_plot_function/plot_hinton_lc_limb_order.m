function h_lcz = plot_hinton_lc_limb_order(weights_lc_fused,limb,parms)

n_limb = size(limb,1);
weights_lc_fused_limb_order = zeros(size(weights_lc_fused));
for i=1:n_limb
    for j=1:2
        weights_lc_fused_limb_order(:,j+2*(i-1))=weights_lc_fused(:,limb(i,j));
    end
end

h_lcz = hinton_LC_limb_1_channel(3,weights_lc_fused_limb_order,parms,limb,1);


end
