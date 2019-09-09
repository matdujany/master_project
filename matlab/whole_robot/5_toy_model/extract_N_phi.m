clear; close all; clc;
addpath('../2_load_data_code');



%% use gait plot to pick t start and t stop
%%%%% quad
recordID = 108; 
n_limb = 4;
t_start = 15;
t_stop = 25;

%%%% hexa
% recordID = 34; %139: n dot %132 hardcoded bipod
% n_limb = 6;
% t_start = 56;
% t_stop = 70;

%%%% octo
% recordID = 50;
% disp('Warning! Pb with phase locking of limb 1');
% n_limb = 8;
% t_start = 60;
% t_stop = 76;


%%
[data, pos_phi_data, parms_locomotion, parms] = load_data_locomotion_processed(recordID);
parms_locomotion.frequency = 0.5;

n_samples_phi = size(pos_phi_data.limb_phi,2);
n_samples_GRF = size(data.time,1);
phi = pos_phi_data.limb_phi;

if abs(n_samples_phi-n_samples_GRF)>1
    disp('Warning ! Number of samples dont agree');
    if n_samples_phi == n_samples_GRF+1
        phi = pos_phi_data.limb_phi(:,2:end);
    end
end
    
phi = phi';

% GRF = zeros(n_samples,n_limb);
for i=1:n_limb
    GRF(:,i) = data.float_value_time{1,i}(:,3);
    GRP(:,i) = data.float_value_time{1,i}(:,2);
end

%filtered version:
size_mv_average = 5;
filter_coeffs = 1/size_mv_average*ones(size_mv_average,1);
GRF_filtered = zeros(size(GRF));
for i=1:n_limb
%     GRF_filtered(:,i) = filter(filter_coeffs,1,GRF(:,i)); %causal
    GRF_filtered(:,i) = filtfilt(filter_coeffs,1,GRF(:,i)); %non-causal
end

GRF=GRF_filtered;


%% plotting parameters
t_start = 38;
t_stop = 58;

time = (data.time(:,1)-data.time(1,1))/10^3;
[~,index_start] = min(abs(time-t_start));
[~,index_stop] = min(abs(time-t_stop));
dot_size = 15;

%%  

figure;
hold on;
for i=1:n_limb
    scatter(phi(index_start:index_stop,i),GRF(index_start:index_stop,i),dot_size,'filled');
    legend_list{i} = ['GRF ' num2str(i)];
end
legend(legend_list);
xlabel('\phi Limb');
xticks(pi/2*[0:4]);
xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
ylim([-1 10]);
ylabel('GRF [N]');
grid on;

%% 



%%

i_limb_ext = 3;

phi_source = phi(index_start:index_stop,i_limb_ext);
GRF_source = GRF(index_start:index_stop,i_limb_ext);

%%
data


% [phi_source, index] = unique(phi_source); 
% GRF_source = GRF_source(index);
% phi_query = linspace(0,2*pi,100)';
% 
% p = polyfit(phi_source,GRF_source,5);
% GRF_guessed = interp1(phi_source,GRF_source,phi_query,'spline');
% GRF_guessed2 = polyval(p,phi_query);
% 
% GRF_guessed3 = spline(phi_source,GRF_source,phi_query);
% 
% 
% 
% figure;
% hold on;
% % scatter(phi(index_start:index_stop,i_limb_ext),GRF(index_start:index_stop,i_limb_ext),dot_size,'filled');
% scatter(phi_source,GRF_source,dot_size,'filled');
% plot(phi_query,GRF_guessed)
% plot(phi_query,GRF_guessed2)
% plot(phi_query,GRF_guessed3)
% xlabel('\phi Limb');
% xticks(pi/2*[0:4]);
% xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
% % ylim([-1 10]);
% ylabel('GRF [N]');
% grid on;
% title(['Limb extracted ' num2str(i_limb_ext)]);