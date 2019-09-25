clear; close all; clc;
addpath('../2_load_data_code');



%% use gait plot to pick t start and t stop
%%%%% quad
% recordID = 108; 
% n_limb = 4;
% t_start = 15;
% t_stop = 25;

%%%% hexa
recordID = 207; %139: n dot %132 hardcoded bipod
n_limb = 6;
t_start = 95;
t_stop = 110;

%%%% octo
% recordID = 50;
% disp('Warning! Pb with phase locking of limb 1');
% n_limb = 8;
% t_start = 60;
% t_stop = 76;

%%
fontSize = 14;
fontSizeTicks = 12;
lineWidth = 1.5;


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
phi_query = linspace(0,2*pi,100)';
for i_limb = 1:n_limb
    phi_source = phi(index_start:index_stop,i_limb);
    GRF_source = GRF(index_start:index_stop,i_limb);
    profile_spline(i_limb) = get_spline_profile(GRF_source,phi_source);
    GRF_from_spline(:,i_limb) = ppval(profile_spline(i_limb),phi_query);
end

%%
figure;
for i_limb = 1:n_limb
    subplot(2,n_limb/2,i_limb);
    hold on;
    % scatter(phi(index_start:index_stop,i_limb_ext),GRF(index_start:index_stop,i_limb_ext),dot_size,'filled');
    scatter(phi(index_start:index_stop,i_limb),GRF(index_start:index_stop,i_limb),dot_size,'filled');
    % plot(phi_grid,GRF_grid,'Linewidth',lineWidth);
    plot(phi_query,GRF_from_spline(:,i_limb),'Linewidth',lineWidth);
    legend('Source data','grid and then spline');
    xlabel('\phi Limb');
    xticks(pi/2*[0:4]);
    xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
    % ylim([-1 10]);
    ylabel('GRF [N]');
    grid on;
    title(['Limb extracted ' num2str(i_limb)]);
end

%%
% filename = ['record_' num2str(recordID) '_limb_' num2str(i_limb_ext)];
% file_name_profile=strcat("profiles/",filename);
% save(file_name_profile,'profile_spline','phi_grid','GRF_grid');

%% Limbs
limits1 = [0 1.23 2.5 3.75 4.9 6.3] ;
[b1,a1] = linear_regression_wrapper(limits1,phi_query,GRF_from_spline(:,1));

limits2 = [0 0.76 2.7 4.7 5.7 6.3] ;
[b2,a2] = linear_regression_wrapper(limits2,phi_query,GRF_from_spline(:,2));

limits3 = [0 0.65 2.65 3.5 4.95 6.3] ;
[b3,a3] = linear_regression_wrapper(limits3,phi_query,GRF_from_spline(:,3));

limits4 = [0 0.9 3.11 3.9 4.3 4.9 6.3] ;
[b4,a4] = linear_regression_wrapper(limits4,phi_query,GRF_from_spline(:,4));

limits5 = [0 0.8 2.6 3.5 5.3 6.0 6.3] ;
[b5,a5] = linear_regression_wrapper(limits5,phi_query,GRF_from_spline(:,5));

limits6 = [0 1.27 2.28 2.73 3.16 4.32 5.01 5.84 6.3] ;
[b6,a6] = linear_regression_wrapper(limits6,phi_query,GRF_from_spline(:,6));

%%
figure;
for i_limb = 1:n_limb
    subplot(2,n_limb/2,i_limb);
    hold on;
    plot(phi_query,GRF_from_spline(:,i_limb),'Linewidth',lineWidth);
    b = eval(strcat('b',num2str(i_limb)));
    a = eval(strcat('a',num2str(i_limb)));    
    limits = eval(strcat('limits',num2str(i_limb))); 
    plot(phi_query,profile_obj(phi_query,limits,b,a),'k--');
    legend('grid and then spline','linear segments');
    xlabel('\phi Limb');
    xticks(pi/2*[0:4]);
    xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
    ylabel('GRF [N]');
    grid on;
    title(['Limb extracted ' num2str(i_limb)]);
end

%%
fprintf('limits = {\n');
for i_limb=1:n_limb
  limits = eval(strcat('limits',num2str(i_limb)));
  n_points = length(limits);
  fprintf('{');
  for k=1:n_points
    fprintf(num2str(limits(k)));
    if k<n_points
        fprintf(',');
    end
  end
  if i_limb<n_limb
    fprintf('},\n');
  else
    fprintf('}\n');
  end
end
fprintf('};\n');


fprintf('a = {\n');
for i_limb=1:n_limb
  a = eval(strcat('a',num2str(i_limb)));
  n_points = length(a);
  fprintf('{');
  for k=1:n_points
    fprintf(num2str(a(k)));
    if k<n_points
        fprintf(',');
    end
  end
  if i_limb<n_limb
    fprintf('},\n');
  else
    fprintf('}\n');
  end
end
fprintf('};\n');

fprintf('b = {\n');
for i_limb=1:n_limb
  b = eval(strcat('b',num2str(i_limb)));
  n_points = length(b);
  fprintf('{');
  for k=1:n_points
    fprintf(num2str(b(k)));
    if k<n_points
        fprintf(',');
    end
  end
  if i_limb<n_limb
    fprintf('},\n');
  else
    fprintf('}\n');
  end
end
fprintf('};\n');


%%

function N = profile_obj(phi,limits,b,a)
%phi is n_samplesx1
n_samples = size(phi,1);
% phi = mod(phi,2*pi);
N = zeros(n_samples,1);
for k=1:n_samples
    for i=1:length(limits)-1
        if phi(k)<limits(i+1)
            N(k,1) = b(i)+a(i)*phi(k);
            break;
        end
    end
end
end

function [b,a] = linear_regression_wrapper(limits,phi,GRF)
for i=1:length(limits)-1
    [b(i),a(i),~] = linear_regression_part(limits(i),limits(i+1),phi,GRF);
end

end

function [a0,a1,x_fit] = linear_regression_part(limit1,limit2,phi_query,GRF_guessed_from_grid)
x_fit = phi_query((limit1<phi_query)&(phi_query<limit2));
y_fit = GRF_guessed_from_grid((limit1<phi_query)&(phi_query<limit2));
[a0,a1]=linear_regression(x_fit,y_fit);
% figure;
% hold on;
% plot(x_fit,y_fit,'b');
% plot(x_fit,a0+a1*x_fit,'r--'); %line

end

function [a0,a1]=linear_regression(x,y)
x=x(:);
y=y(:);
X=[x,ones(numel(x),1)];
a = (X'*X)\(X'*y);
a0=a(2);
a1=a(1);
end