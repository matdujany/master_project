function h_speed = plot_hinton_speed_limb_order(weights_speed_fused,limb)

n_limb = size(limb,1);
weights_speed_fused_limb_order = zeros(size(weights_speed_fused));
for i=1:n_limb
    for j=1:2
        weights_speed_fused_limb_order(:,j+2*(i-1))=weights_speed_fused(:,limb(i,j));
    end
end

h_speed = hinton_speed_limb(weights_speed_fused_limb_order,limb,1);


end

