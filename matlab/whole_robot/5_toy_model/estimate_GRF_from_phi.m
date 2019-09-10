function GRF = estimate_GRF_from_phi(phi,total_load,n_limb,profilparms)
%GRF is (n_limb,1) column vector
%phi is (n_limb,1) column vector


% GRF = estimate_GRF_from_phi_method1(phi,total_load);
% GRF = GRF.*(1-sin(phi))/2; 

% GRF = estimate_GRF_from_profile(phi,total_load,n_limb);
GRF = estimate_GRF_from_profile(phi,profilparms.recordID,profilparms.i_limb);

GRF(:,sum(GRF,1)>0) = total_load * GRF(:,sum(GRF,1)>0) ./sum(GRF(:,sum(GRF,1)>0),1);
% if sum(GRF)>0
%     GRF = total_load/sum(GRF) * GRF;
% end

end

function GRF = estimate_GRF_from_phi_method2(phi,total_load)

n_limb = length(phi);
GRF = zeros(n_limb,1);

idx_legs_right = [1:n_limb/2];
idx_legs_left = [n_limb/2+1:n_limb];
idx_split_side = [idx_legs_right; idx_legs_left];
total_load_side = total_load/2;

for i_side = 1:2
    idx_legs_stance = find(mod(phi(idx_split_side(i_side,:)),2*pi) >= pi);
    n_legs_stance = length(idx_legs_stance);
    for i=1:n_legs_stance
        GRF(idx_split_side(i_side,idx_legs_stance),1) = total_load_side/n_legs_stance;
    end
    if n_legs_stance == 0
        GRF(idx_split_side(i_side,:),1) = total_load_side/(n_limb/2);
    end
end



end

function GRF = estimate_GRF_from_phi_method1(phi,total_load)

phi = mod(phi,2*pi);
% idx_legs_stance = find(mod(phi,2*pi) >= pi);
n_legs_stance = sum(phi>=pi,1);

n_limb = size(phi,1);
GRF = zeros(size(phi,1),size(phi,2));

GRF(:,n_legs_stance == 0) = total_load/n_limb;
% GRF(:, n_legs_stance>0) = repmat(total_load./n_legs_stance(n_legs_stance>0),n_limb,1);
GRF(:, n_legs_stance>0) = repmat(total_load./n_legs_stance(n_legs_stance>0),n_limb,1);

% for i=1:n_legs_stance
%     GRF(idx_legs_stance(i),1) = total_load/n_legs_stance;
% end


end