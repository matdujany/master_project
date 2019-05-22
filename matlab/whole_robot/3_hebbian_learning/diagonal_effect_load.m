clear; 
close all; clc;


addpath('../2_load_data_code');
addpath('../../tight_subplot');
addpath('hinton_plot_functions');
addpath('computing_functions');

%% Load data
recordID = 102;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);

% %%
% weights_robotis  = read_weights_robotis(recordID,parms);
% hinton_LC(weights_robotis{parms.n_twitches},parms,1);
% 

%%
n_actions = parms.n_twitches * parms.n_m * 2;
static_load = zeros(parms.n_lc,parms.n_twitches, 2*parms.n_m);
static_load_actions = zeros(parms.n_lc,n_actions);

n_frames_theo = get_theo_number_frames(parms);

for k = 1:parms.n_twitches
    for index_motor = 1:2*parms.n_m
        index_start = n_frames_theo.per_twitch*(k-1) + ...
    (n_frames_theo.per_action)*(index_motor-1)+ 1;
        index_end = index_start + n_frames_theo.part0 - 1;
        for i_lc = 1:parms.n_lc
            static_load(i_lc,k,index_motor) = mean(data.float_value_time{1,i_lc}(index_start:index_end,3));
        end
    end
end

for count_action = 1:n_actions
    index_start = (n_frames_theo.per_action)*(count_action-1)+ 1;
    index_end = index_start + n_frames_theo.part0 - 1;
    for i_lc = 1:parms.n_lc
        static_load_actions(i_lc,count_action) = mean(data.float_value_time{1,i_lc}(index_start:index_end,3));
    end
end

%%
figure;
legend_list = cell(parms.n_lc,1);
hold on;
for i_lc = 1:parms.n_lc
    plot(static_load_actions(i_lc,:));
    legend_list{i_lc,1} = ['LC ' num2str(i_lc)];
end
ax=gca();
for k=1:parms.n_twitches-1
    end_twitch = (parms.n_m * 2)*k+0.5;
    plot([end_twitch end_twitch],ax.YLim,'k--');
end
ylabel('Mean Z static load before action [N]');
xlabel('Twitch movement count');
legend(legend_list);

%%
mean_static_load=squeeze(mean(static_load,2))
% for i_motor = 1:oarn

