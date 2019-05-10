function simulated_limb_phi = compute_phi_wrapper(pos_phi_data,GRF,parms_locomotion)
%COMPUTE_PHI Summary of this function goes here
%   Detailed explanation goes here
if isfield(parms_locomotion,'use_filter') && parms_locomotion.use_filter
    size_mv_average = parms_locomotion.filter_size+1;
    filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
    GRF_filtered = zeros(size(GRF));
    for i=1:size(GRF_filtered,2)
        GRF_filtered(:,i) =  filter(filter_coeffs,1,GRF(:,i));
    end 
    simulated_limb_phi = compute_phi(pos_phi_data,GRF_filtered,parms_locomotion);
else
    simulated_limb_phi = compute_phi(pos_phi_data,GRF,parms_locomotion);
end
end


function simulated_limb_phi = compute_phi(pos_phi_data,GRF,parms_locomotion)
%COMPUTE_PHI Summary of this function goes here
%   Detailed explanation goes here
simulated_limb_phi = zeros(size(pos_phi_data.limb_phi));
simulated_limb_phi(:,1) = pos_phi_data.limb_phi(:,1);
for i=2:size(simulated_limb_phi,2)
    for i_limb = 1:size(simulated_limb_phi,1)
        earlier_phase = simulated_limb_phi(i_limb,i-1);
        if strfind(parms_locomotion.categoryName,"tegotae_advanced")>0
            phi_dot = advanced_tegotae_rule(i_limb,earlier_phase,GRF(i-1,:),parms_locomotion);
        else
            phi_dot = simple_tegotae_rule(earlier_phase,GRF(i-1,i_limb),parms_locomotion);
        end
        simulated_limb_phi(i_limb,i)=earlier_phase+phi_dot*(pos_phi_data.phi_update_timestamp(i)-pos_phi_data.phi_update_timestamp(i-1))/1000;
    end
end
end

