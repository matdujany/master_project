function simulated_limb_phi = compute_phi_wrapper(pos_phi_data,GRF,parms_locomotion)
%COMPUTE_PHI Summary of this function goes here
%   Detailed explanation goes here

%if filter
if isfield(parms_locomotion,'use_filter') && parms_locomotion.use_filter
    size_mv_average = parms_locomotion.filter_size+1;
    filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
    GRF_filtered = zeros(size(GRF));
    for i=1:size(GRF_filtered,2)
        GRF_filtered(:,i) =  filter(filter_coeffs,1,GRF(:,i));
    end
    GRF = GRF_filtered;
end

%if changes in the record
if isfield(parms_locomotion,'n_change') && parms_locomotion.n_change>0
    n_parts = parms_locomotion.n_change + 1;
    index_start_part(1) = 1;
    for k=1:n_parts-1
        index_end_part(k) = find(pos_phi_data.phi_update_timestamp>parms_locomotion.time_change(k)*10^3,1)-1;
        index_start_part(k+1) = find(pos_phi_data.phi_update_timestamp>parms_locomotion.time_change(k)*10^3,1);
    end
    index_end_part(n_parts) = length(pos_phi_data.phi_update_timestamp);
    
    for k=1:n_parts
        phi_init = pos_phi_data.limb_phi(:,index_start_part(k));
        timestamps = pos_phi_data.phi_update_timestamp(index_start_part(k):index_end_part(k));
        GRF_part = GRF(index_start_part(k):index_end_part(k),:);
        frequency_part = parms_locomotion.frequencies(k);
        if strfind(parms_locomotion.categoryName,"tegotae_advanced")>0
            sigma_advanced_part = parms_locomotion.sigma_advanced(k);
            simulated_limb_phi = compute_phi(phi_init,timestamps,GRF_part,parms_locomotion,frequency_part,sigma_advanced_part);
        else
            sigma_simple_part = parms_locomotion.sigma_simple(k);
            simulated_limb_phi = compute_phi(phi_init,timestamps,GRF_part,parms_locomotion,frequency_part,sigma_simple_part);
        end
    end

else
    phi_init = pos_phi_data.limb_phi(:,1);
    timestamps = pos_phi_data.phi_update_timestamp;
    if strfind(parms_locomotion.categoryName,"tegotae_advanced")>0
        simulated_limb_phi = compute_phi(phi_init,timestamps,GRF,parms_locomotion,parms_locomotion.frequency,parms_locomotion.sigma_advanced);
    else
        simulated_limb_phi = compute_phi(phi_init,timestamps,GRF,parms_locomotion,parms_locomotion.frequency,parms_locomotion.sigma_s);
    end  
end

end

% function simulated_limb_phi = compute_phi_filtered(phi_init,timestamps,GRF,parms_locomotion)
%     size_mv_average = parms_locomotion.filter_size+1;
%     filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
%     GRF_filtered = zeros(size(GRF));
%     for i=1:size(GRF_filtered,2)
%         GRF_filtered(:,i) =  filter(filter_coeffs,1,GRF(:,i));
%     end 
%     simulated_limb_phi = compute_phi(pos_phi_data,GRF_filtered,parms_locomotion);
% end


% function simulated_limb_phi = compute_phi(pos_phi_data,GRF,parms_locomotion)
% %COMPUTE_PHI Summary of this function goes here
% %   Detailed explanation goes here
% simulated_limb_phi = zeros(size(pos_phi_data.limb_phi));
% simulated_limb_phi(:,1) = pos_phi_data.limb_phi(:,1);
% for i=2:size(simulated_limb_phi,2)
%     for i_limb = 1:size(simulated_limb_phi,1)
%         earlier_phase = simulated_limb_phi(i_limb,i-1);
%         if strfind(parms_locomotion.categoryName,"tegotae_advanced")>0
%             phi_dot = advanced_tegotae_rule(i_limb,earlier_phase,GRF(i-1,:),parms_locomotion);
%         else
%             phi_dot = simple_tegotae_rule(earlier_phase,GRF(i-1,i_limb),parms_locomotion);
%         end
%         simulated_limb_phi(i_limb,i)=earlier_phase+phi_dot*(pos_phi_data.phi_update_timestamp(i)-pos_phi_data.phi_update_timestamp(i-1))/1000;
%     end
% end
% end

function simulated_limb_phi = compute_phi(phi_init,timestamps,GRF,parms_locomotion,frequency,sigma)
%COMPUTE_PHI Summary of this function goes here
%   timestamps are the times of update of timestamp should be 1xn_samples
%   GRF should be n_samples x n_limb
simulated_limb_phi = zeros(size(GRF,2),length(timestamps));
simulated_limb_phi(:,1) = phi_init;
for i=2:length(timestamps)
    for i_limb = 1:size(GRF,2)
        earlier_phase = simulated_limb_phi(i_limb,i-1);
        if strfind(parms_locomotion.categoryName,"tegotae_advanced")>0
            if nargin == 5
                [inverse_map,sigma] = load_inverse_map(parms_locomotion.direction,parms_locomotion.id_map_used);
            else
                [inverse_map,~] = load_inverse_map(parms_locomotion.direction,parms_locomotion.id_map_used);
            end
            phi_dot = advanced_tegotae_rule(i_limb,earlier_phase,GRF(i-1,:),inverse_map,frequency,sigma);
        else
            phi_dot = simple_tegotae_rule(earlier_phase,GRF(i-1,i_limb),frequency,sigma);
        end
        simulated_limb_phi(i_limb,i)=earlier_phase+phi_dot*(timestamps(i)-timestamps(i-1))/1000;
    end
end
end


