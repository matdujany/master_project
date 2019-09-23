clear; close all; clc;
addpath('../2_load_data_code');


%%
recordID = 206;

[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);

n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);
n_limb = size(data.time,2)-1;
phi = pos_phi_data.limb_phi;

if abs(n_samples_phi-n_samples_GRF)>1
    disp('Warning ! Number of samples dont agree');
    if n_samples_phi == n_samples_GRF+1
        phi = pos_phi_data.limb_phi(:,2:end);
    end
end
    
phi = phi';

GRF = zeros(n_samples_GRF,n_limb);
GRP = zeros(n_samples_GRF,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end


%% computing phase updates
phi_dots = zeros(size(phi)-[1 0]);
diff_phi = diff(phi);
diff_phi(diff_phi<-6) = diff_phi(diff_phi<-6)+2*pi;
for i=1:n_limb
    phi_dots(:,i) = 10^3*diff_phi(:,i)./diff(pos_phi_data.phi_update_timestamp)' - 2*pi*parms_locomotion.frequency;
%     phase_updates(:,i) = diff_phi(:,i)./0.021 - 2*pi*parms_locomotion.frequency;

end

%% computing Tegotae feedback terms value
if isfield(parms_locomotion,'complete_rule') && parms_locomotion.complete_rule == 1
    disp('Using sigma values from parms_locomotion');
    sigma_hip = parms_locomotion.sigma_hip;
    sigma_knee = parms_locomotion.sigma_knee;
    sigma_p_hip = parms_locomotion.sigma_p_hip;
    sigma_p_knee = parms_locomotion.sigma_p_knee;
else
    disp('Using user values for sigma values (maybe not suited to recording)');
    sigma_hip = 0; %0.15;
    sigma_knee = 0;
    sigma_p_hip = 0;
    sigma_p_knee = 1.5;
end
[u_hip,u_knee,v_hip,v_knee] = load_matrix_complete_rule();
feedback_terms = zeros(n_samples_GRF,n_limb,4);
feedback_terms(:,:,1) = sigma_hip*(u_hip*GRF')'.*cos(phi);
feedback_terms(:,:,2) = sigma_knee*(u_knee*GRF')'.*sin(phi);
feedback_terms(:,:,3) = - sigma_p_hip*(v_knee*GRP')'.*cos(phi);
feedback_terms(:,:,4) = - sigma_p_knee*(v_knee*GRP')'.*sin(phi);

feedback = sum(feedback_terms,3);

%%
i_limb_plot = 1;
figure;
hold on;
plot(data.time(2:end,i_limb_plot)/10^3,phi_dots(:,i_limb_plot));
plot(data.time(:,i_limb_plot)/10^3,feedback_terms(:,i_limb_plot,1));
plot(data.time(:,i_limb_plot)/10^3,feedback_terms(:,i_limb_plot,4));
legend('Phi dot','Z load term','Propulsion term');
xlabel('Time [s]'),
ylim(5*[-1 1]);
