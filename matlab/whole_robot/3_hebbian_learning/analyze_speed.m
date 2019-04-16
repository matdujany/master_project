clear; 
close all; clc;

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 14;
[data, lpdata, parms] =  load_data_processed(recordID);
add_parms;
weights_robotis = read_weights_robotis(recordID,parms);
weights_pos_robotis = read_weights_pos_robotis(recordID,parms);


hinton_IMU(weights_robotis{parms.n_twitches},parms);

weights_speed = compute_weights_speed(data,lpdata,parms);

%%
hinton_speed(weights_speed{parms.n_twitches},parms);
plot_weight_evolution_speed(weights_speed,parms);

%%
integrated_speed = compute_integrated_speed(data,lpdata,parms);

twitch_cycle_idx = 1;
n_frames_theo = get_theo_number_frames(parms);
index_start = 1 + n_frames_theo.per_twitch*(twitch_cycle_idx-1);
index_end = n_frames_theo.per_twitch*twitch_cycle_idx;
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
n_action = (parms.n_m*parms.n_dir);
idx_start_learning = pos_start_learning(1+n_action*(twitch_cycle_idx-1):n_action*twitch_cycle_idx);  
idx_end_learning = pos_end_learning(1+n_action*(twitch_cycle_idx-1):n_action*twitch_cycle_idx);  

figure;
text_list_channels = {'X','Y','Z'};
for i=1:3
subplot(2,2,i);
hold on;
plot(integrated_speed(index_start:index_end,i));
plot(myfilter(integrated_speed(index_start:index_end,i)));
plot_patch_learning(gcf(),idx_start_learning,idx_end_learning,1);

legend('Filtered IMU integrated','Filtered IMU integrated then filtered');
ylabel(['Speed ' text_list_channels{i} ' [m/s]']);
end
sgtitle('IMU accelerometer integrated signal');

%% 
test_method(1,data,lpdata,parms);
test_method(2,data,lpdata,parms);
test_method(3,data,lpdata,parms);

%%
function test_method(method,data,lpdata,parms)
integrated_speed = compute_integrated_speed(data,lpdata,parms);
sign_motor_dirs = compute_sign_data_speed(method,integrated_speed,data,lpdata,parms);

%%
data_pixels = sum(sign_motor_dirs,3);
plot_results_speed_effects(data_pixels,parms,['Method ' num2str(method)]);
end

function sign_motor_dirs = compute_sign_data_speed(method,integrated_speed,data,lpdata,parms)
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
count_movement = 1;
sign_motor_dirs = zeros(3,2*parms.n_m,parms.n_twitches);
for k=1:parms.n_twitches
    for n_motor=1:2*parms.n_m
        data_speed = integrated_speed(pos_start_learning(count_movement):pos_end_learning(count_movement),:);
        switch method
            case 1
                sign_motor_dirs(:,n_motor,k) = get_sign_data_speed_m1(data_speed);
            case 2
                sign_motor_dirs(:,n_motor,k) = get_sign_data_speed_m2(data_speed);
            case 3
                sign_motor_dirs(:,n_motor,k) = sign(mean(data_speed,1));
            otherwise
                disp('unrecognized method');
                return;
        end
        count_movement = count_movement + 1;
    end
end
if count_movement-1 ~= length(pos_start_learning)
    disp('Pb wit number of movements');
end

end

% second method, take sign of first value past threshold
function signs = get_sign_data_speed_m2(data_speed,threshold)
if nargin == 1
    threshold = 1*10^-3; %in m/s
end
signs = zeros(size(data_speed,2),1);
for dir=1:size(data_speed,2)
    index_sup_threshold = find(abs(data_speed(:,dir))>threshold);
    if ~isempty(index_sup_threshold)
        signs(dir) = sign(data_speed(index_sup_threshold(1),dir));
    end
end
end

%first method, take sign of max absolute value
function signs = get_sign_data_speed_m1(data_speed)
signs = zeros(size(data_speed,2),1);
for dir=1:size(data_speed,2)
    [~,index_max] = max(abs(data_speed(:,dir)));
    signs(dir) = sign(data_speed(index_max,dir));
end
end

function plot_results_speed_effects(data_pixels,parms,titleString)

fontsize= 14;

motor_tick_label_list = cell(2*parms.n_m,1);
for i=1:2*parms.n_m
    if mod(i,2) == 1
        sign = '-';
    else
        sign = '+';
    end
    motor_tick_label_list{i} = ['M' num2str(ceil(i/2)) sign];
end
dir_label_list = {' X',' Y',' Z'};

f=figure;
colormap gray;
for dir=1:3
    subplot(3,1,dir)
    hold on;
    image(data_pixels(dir,:),'CDataMapping','scaled');
    for i=1:parms.n_m-1
        plot(2*i*[1 1]+0.5,[0.5 1.5],'r--');
    end
    plot([0.5 0.5],[0.5 1.5],'k-');
    plot([0.5 0.5]+2*parms.n_m,[0.5 1.5],'k-');
    plot([0.5 0.5+2*parms.n_m],[0.5 0.5],'k-');
    plot([0.5 0.5+2*parms.n_m],[1.5 1.5],'k-');   
    hold off;
    caxis manual
    caxis(parms.n_twitches*[-1 1]);
%     title(strcat('Direction ',dir_label_list{1,dir}));
%     yticks([]);
    yticks([1]);
    yticklabels(dir_label_list{1,dir});
    xticks(1:2*parms.n_m);
    xlim([0.5 2*parms.n_m+0.5]);
    xticklabels(motor_tick_label_list);
%     set(gca,'TickLength',[0.1 0.1]);
    ax = gca();
    ax.FontSize=fontsize;
    ax.Visible = 'on';
end
colorbar('location','Manual', 'position', [0.93 0.12 0.02 0.73]);

sgtitle(titleString,'FontSize',fontsize);

f.Color = 'w';
end
