function [dN_dphi,dN_dphi_grid, profile_spline_N] = compute_dN_dphi(i_limb,time,phi,GRF,duration_per_limb,flagPlot)
%COMPUTE_DN_DPHI Summary of this function goes here
%   Detailed explanation goes here

t_start = duration_per_limb*(i_limb-1);
t_stop = duration_per_limb*i_limb;
[~, i_start] = min(abs(time-t_start));
[~, i_stop] = min(abs(time-t_stop));

n_limb = size(GRF,2);

n_limb_plot = 6;

pi_label_list = {'0','\pi/2','\pi','3\pi/2','2\pi'};

if flagPlot
    figure;
    hold on;
    for i=1:n_limb_plot
        scatter(phi(i_start:i_stop,i_limb),GRF(i_start:i_stop,i));
        legend_list{i} = ['N ' num2str(i)];
    end
    xlabel(['Phase \phi_ ' num2str(i_limb) ' [rad]']);
    xticks(pi/2*[0:4])
    xticklabels(pi_label_list);
    xlim([0 2*pi]);
    ylabel('GRF [N]');
    legend(legend_list);
end


%% padding to make it really periodic

phi_extracted = phi(i_start:i_stop,i_limb);
N_extracted = GRF(i_start:i_stop,:);

phi_grid = uniquetol(phi_extracted,10^-2);
N_grid = zeros(length(phi_grid),n_limb);

for i=1:length(phi_grid)
    idx_tmp = phi_grid(i)==phi_extracted;
    N_grid(i,:) = mean(N_extracted(idx_tmp,:),1);
end

margin_pad = 1; %in radians

[~,idx1] = min(abs(phi_grid-margin_pad));
phi_grid_padded = [phi_grid; 2*pi + phi_grid(1:idx1)];
N_padded = [N_grid; N_grid(1:idx1,:)];

[~,idx2] = min(abs(phi_grid-(2*pi-margin_pad)));
phi_grid_padded = [ - 2*pi + phi_grid(idx2:end); phi_grid_padded];
N_padded = [N_grid(idx2:end,:); N_padded];

%%
if flagPlot
    figure;
    hold on;
    for i=1:n_limb_plot
        scatter(phi_grid_padded,N_padded(:,i));
    end
    xlabel(['Phase \phi_ ' num2str(i_limb) ' [rad]']);
    xticks(pi/2*[0:4])
    xticklabels(pi_label_list);
    xlim([0 2*pi]);
    ylabel('GRF [N]');
    legend(legend_list);
end
%%
phi_query = linspace(-margin_pad,2*pi+margin_pad,200)';
N_guessed_from_grid = zeros(length(phi_query),n_limb);
for i=1:n_limb
    profile_spline_N(i) = spline(phi_grid_padded,N_padded(:,i));
    N_guessed_from_grid(:,i) = ppval(profile_spline_N(i),phi_query);
end

if flagPlot
    figure;
    hold on;
    for i=1:n_limb_plot
        plot(phi_query,N_guessed_from_grid(:,i));
        legend_list{i} = ['N ' num2str(i)];
    end
    xlabel(['Phase \phi_ ' num2str(i_limb) ' [rad]']);
    xticks(pi/2*[0:4])
    xticklabels(pi_label_list);
    xlim([0 2*pi]);
    ylabel('GRF [N]');
    title('Spline approximation');
    legend(legend_list);
end

for i=1:n_limb
    N_smoothed(:,i) = smooth(N_guessed_from_grid(:,i),50,'rloess');
end

if flagPlot
    figure;
    hold on;
    for i=1:n_limb_plot
        plot(phi_query,N_smoothed(:,i));
        legend_list{i} = ['N ' num2str(i)];
    end
    ylabel('GRF [N]');
    xlabel(['Phase \phi_ ' num2str(i_limb) ' [rad]']);
    xticks(pi/2*[0:4])
    xticklabels(pi_label_list);
    xlim([0 2*pi]);
    title('After smoothing');
    legend(legend_list);
end

% delta_phi = 2*pi*parms_locomotion.frequency * (25*10^-3); % 25 ms, delay update tegotae;

dN_dphi = diff(N_smoothed)./diff(phi_query);
dN_dphi_grid = (phi_query(1:end-1) + phi_query(2:end))/2;

if flagPlot
    figure;
    hold on;
    for i=1:n_limb_plot
        plot(dN_dphi_grid,dN_dphi(:,i));
    end
    ylabel('dN/d\phi [N/rad]');
    xlabel(['Phase \phi_ ' num2str(i_limb) ' [rad]']);
    xticks(pi/2*[0:4])
    xticklabels(pi_label_list);
    xlim([0 2*pi]);
    legend(legend_list);
end

end

