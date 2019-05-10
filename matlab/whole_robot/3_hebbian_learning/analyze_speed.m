clear; 
close all; clc;

addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 91;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);
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
sign_motor_dirs1 = compute_sign_data_speed(1,integrated_speed,data,lpdata,parms);
sign_motor_dirs2 = compute_sign_data_speed(2,integrated_speed,data,lpdata,parms);
sign_motor_dirs3 = compute_sign_data_speed(3,integrated_speed,data,lpdata,parms);

figure;
text_list_channels = {'X','Y','Z'};
for i_dir=1:3
subplot(2,2,i_dir);
hold on;
plot(integrated_speed(index_start:index_end,i_dir));
ax = gca();
plot_patch_learning(ax.YLim,idx_start_learning,idx_end_learning,0);
for i_motor=1:2*parms.n_m
    text((idx_start_learning(i_motor)+idx_end_learning(i_motor))/2,ax.YLim(2)*0.8,num2str(sign_motor_dirs1(i_dir, i_motor,twitch_cycle_idx)));
    text((idx_start_learning(i_motor)+idx_end_learning(i_motor))/2,ax.YLim(2)*0.9,num2str(sign_motor_dirs2(i_dir, i_motor,twitch_cycle_idx)));
    text((idx_start_learning(i_motor)+idx_end_learning(i_motor))/2,ax.YLim(2),num2str(sign_motor_dirs3(i_dir, i_motor,twitch_cycle_idx)));
end
ylim(ax.YLim);
ylabel(['Speed ' text_list_channels{i_dir} ' [m/s]']);
text(ax.XLim(2),ax.YLim(2)*0.8,'Method 1 : max');
text(ax.XLim(2),ax.YLim(2)*0.9,'Method 2 : threshold');
text(ax.XLim(2),ax.YLim(2)*1,'Method 3 : average');

end
sgtitle('IMU accelerometer integrated signal');

%% 
test_method(1,data,lpdata,parms);
% test_method(2,data,lpdata,parms);
test_method(3,data,lpdata,parms);

%%
average_speeds = compute_average_speeds(integrated_speed,data,lpdata,parms);
plot_results_speed_effects_2(sum(average_speeds,3),parms,'Summing all averages');

%% plot 1 motor
figure;
idx_motor = 2;
i_dir = 1; %1 for X
for i=1:parms.n_twitches
    subplot(1,parms.n_twitches,i);
    hold on;
    idx_start_motor = 1 + n_frames_theo.per_twitch*(i-1) + n_frames_theo.per_action*(idx_motor-1);
    idx_end_motor = idx_start_motor + n_frames_theo.per_action;
    plot(integrated_speed(idx_start_motor:idx_end_motor,i_dir));
    ax = gca();
    text(n_frames_theo.part0,ax.YLim(2)*0.8,['Method 1 : ' num2str(sign_motor_dirs1(i_dir, idx_motor,i))]);
    text(n_frames_theo.part0,ax.YLim(2)*0.9,['Method 2 : ' num2str(sign_motor_dirs2(i_dir, idx_motor,i))]);
    text(n_frames_theo.part0,ax.YLim(2)*1.0,['Method 3 : ' num2str(sign_motor_dirs3(i_dir, idx_motor,i))]);
    hold off;
end

function test_method(method,data,lpdata,parms)
integrated_speed = compute_integrated_speed(data,lpdata,parms);
sign_motor_dirs = compute_sign_data_speed(method,integrated_speed,data,lpdata,parms);

%%
data_pixels = sum(sign_motor_dirs,3);
titleStrings = {'Method 1 : max','Method 2 : threshold','Method 3 : average'};
plot_results_speed_effects(data_pixels,parms,titleStrings{1,method});
end

function average_speeds = compute_average_speeds(integrated_speed,data,lpdata,parms)
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
count_movement = 1;
average_speeds = zeros(3,2*parms.n_m,parms.n_twitches);

for k=1:parms.n_twitches
    for n_motor=1:2*parms.n_m
        data_speed = integrated_speed(pos_start_learning(count_movement):pos_end_learning(count_movement),:);
        average_speeds(:,n_motor,k) = mean(data_speed,1);
        count_movement = count_movement + 1;
    end
end
if count_movement-1 ~= length(pos_start_learning)
    disp('Pb wit number of movements');
end
end


function sign_motor_dirs = compute_sign_data_speed(method,integrated_speed,data,lpdata,parms)
[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);
count_movement = 1;
sign_motor_dirs = zeros(3,2*parms.n_m,parms.n_twitches);
average_speeds = zeros(3,2*parms.n_m,parms.n_twitches);

for k=1:parms.n_twitches
    for n_motor=1:2*parms.n_m
        data_speed = integrated_speed(pos_start_learning(count_movement):pos_end_learning(count_movement),:);
        average_speeds(:,n_motor,k) = mean(data_speed,1);
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

function plot_results_speed_effects_2(data_pixels,parms,titleString)

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
%     title(strcat('Direction ',dir_label_list{1,dir}));
%     yticks([]);
    yticks([1]);
    yticklabels(dir_label_list{1,dir});
    xticks(1:2*parms.n_m);
    xlim([0.5 2*parms.n_m+0.5]);
    xticklabels(motor_tick_label_list);
    caxis manual
    caxis(max(max(abs(data_pixels(dir,:))))*[-1 1]);
%     set(gca,'TickLength',[0.1 0.1]);
    ax = gca();
    ax.FontSize=fontsize;
    ax.Visible = 'on';
    colorbar;
end
% colorbar('location','Manual', 'position', [0.93 0.12 0.02 0.73]);

sgtitle(titleString,'FontSize',fontsize);

f.Color = 'w';
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
colormap gray(11);
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
    caxis(parms.n_twitches*[-1 1]+[-0.5 0.5]);
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
colorbar('location','Manual', 'position', [0.93 0.12 0.02 0.73],'YTick',-parms.n_twitches:2:parms.n_twitches);

sgtitle(titleString,'FontSize',fontsize);

f.Color = 'w';
end
