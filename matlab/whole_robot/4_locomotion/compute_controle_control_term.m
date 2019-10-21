function [feedback,check_feedback] = compute_controle_control_term(GRF,GRP,phi,phi_update_timestamp,frequency,sigma_hip,sigma_knee,sigma_p_hip, sigma_p_knee,u_hip,u_knee,v_hip,v_knee,flag_control_in_stance_only)
%COMPUTE_CONTROLE_CONTROL_TERM Summary of this function goes here
%   Detailed explanation goes here

[n_samples_GRF, n_limb]= size(GRF);

feedback_terms = zeros(n_samples_GRF,n_limb,4);


feedback_terms(:,:,1) = sigma_hip*(u_hip*GRF')'.*cos(phi);
feedback_terms(:,:,2) = sigma_knee*(u_knee*GRF')'.*sin(phi);
feedback_terms(:,:,3) = - sigma_p_hip*(v_hip*GRP')'.*cos(phi);
feedback_terms(:,:,4) = - sigma_p_knee*(v_knee*GRP')'.*sin(phi);

feedback = sum(feedback_terms,3);
feedback(sum(GRF,2)<5,:) = 0;

%%
if flag_control_in_stance_only
    feedback = feedback.*(phi>pi);
end

%% checking that delta phi - 2*pi
phi_dots = zeros(size(phi)-[1 0]);
diff_phi = diff(phi);
diff_phi(diff_phi<-6) = diff_phi(diff_phi<-6)+2*pi;
for i=1:n_limb
    phi_dots(:,i) = 10^3*diff_phi(:,i)./diff(phi_update_timestamp)' - 2*pi*frequency;
end
check_feedback = phi_dots - feedback(1:end-1,:);

end

