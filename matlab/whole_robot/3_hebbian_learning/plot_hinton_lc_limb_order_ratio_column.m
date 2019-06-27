function [h_lcz,weights_lcz_fused_limb_order_ratios] = plot_hinton_lc_limb_order_ratio_column(weights_lc_fused,limb,parms)

n_limb = size(limb,1);
weights_lc_fused_limb_order = zeros(size(weights_lc_fused));
for i=1:n_limb
    for j=1:2
        weights_lc_fused_limb_order(:,j+2*(i-1))=weights_lc_fused(:,limb(i,j));
    end
end

weights_lcz_fused_limb_order = weights_lc_fused_limb_order(3*[1:n_limb],:);
weights_lcz_fused_limb_order_ratios = zeros(size(weights_lcz_fused_limb_order));

for i=1:n_limb
    for j=1:2
        weights_lcz_fused_limb_order_ratios(:,j+2*(i-1))=weights_lcz_fused_limb_order(:,j+2*(i-1))/max(abs(weights_lcz_fused_limb_order(:,j+2*(i-1))));
    end
end


h_lcz = hinton_LC_limb_1_channel(0,weights_lcz_fused_limb_order_ratios,parms,limb,1);


end