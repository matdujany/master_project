function GRF = estimate_GRF_from_profile(phi,total_load,n_limb)

n_points = length(phi);

[phi_obj,N_obj] = get_N_profile(total_load,n_limb);
phi = mod(phi,2*pi);

%just a little trick to make sure phi_obj goes past 2*pi.
% phi_obj(end+1) = phi_obj(1)+2*pi; 
% N_obj(end+1) = N_obj(1);

GRF = zeros(n_points,1);

for i=1:n_points
    [dist,idx]=sort(abs(phi_obj-phi(i,1)));

    if dist(1) == 0
        GRF(i,1) = N_obj(idx(1));
    else
        a = (N_obj(idx(2)) - N_obj(idx(1)))/(phi_obj(idx(2)) - phi_obj(idx(1)));
        GRF(i,1) = N_obj(idx(1)) + a * (phi(i,1) - phi_obj(idx(1)));
    end
    if(GRF(i,1)==Inf)
        disp('GRF inf');
    end
end

end



% 
% for i=1:n_limb
%     if sum(phi_obj==phi(i,1))  == 0
%         [~,idx_down] = max(phi_obj(phi_obj<phi(i,1)));
%         [~,idx_up] = min(phi_obj(phi_obj>phi(i,1)));
%         if isempty(idx_down)
%             disp('idx down empty');
%         end
%         if isempty(idx_down)
%             disp('idx down empty');
%         end
%         a = (N_obj(idx_up) - N_obj(idx_down))/(phi_obj(idx_up) - phi_obj(idx_down));
%         GRF(i,1) = N_obj(idx_down) + a * (phi(i,1) - phi_obj(idx_down));
%     else
%         GRF(i,1) = N_obj(phi_obj==phi(i,1));
%     end
% 
% end