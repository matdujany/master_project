
clear;
close all; clc;

addpath('hinton_plot_functions');
addpath('computing_functions');
addpath('../2_load_data_code');
addpath('../../tight_subplot');

%% Load data
recordID = 105;
[data, lpdata, parms] =  load_data_processed(recordID);
parms=add_parms(parms);

n_frames_theo = get_theo_number_frames(parms);

% index_start_twitch = 1+n_frames_theo.per_twitch*(idx_twitch-1);
% index_start_motor = index_start_twitch+n_frames_theo.per_action*2*(i_motor-1);
% index_end_motor = index_start_motor+2*n_frames_theo.per_action-1;

n_moves = parms.n_twitches * parms.n_m * 2;
lc_values_recentering = zeros(n_moves*n_frames_theo.part0, parms.n_lc);

for i=1:n_moves
    for i_lc = 1:parms.n_lc
        lc_values_recentering( 1+(i-1)*n_frames_theo.part0 : i*n_frames_theo.part0,i_lc) = ...
        data.float_value_time{1,i_lc}( 1+(i-1)*n_frames_theo.per_action : (i-1)*n_frames_theo.per_action + n_frames_theo.part0 ,3);
    end
end

%%
addpath('../4_locomotion');
[inverse_map,sigma_advanced] = get_inverse_map("X",recordID);
total_load = get_total_load(recordID,parms);

%%
figure;
for i = 1:parms.n_lc
    subplot(2,parms.n_lc/2,i);
    hold on;
    plot(lc_values_recentering(:,i));
    plot([1 n_moves*n_frames_theo.part0],total_load/parms.n_lc*[1 1],'k--');
    ylim(total_load/parms.n_lc + 0.5*[-1 1]);
    title(['LC ' num2str(i)]);
end


%%
map_term = (inverse_map*lc_values_recentering')';

figure;
for i = 1:parms.n_lc
    subplot(2,parms.n_lc/2,i);
    hold on;
    plot(map_term(:,i));
    plot([1 n_moves*n_frames_theo.part0],0*[1 1],'k--');
    ylim(1*[-1 1]);
    title(['Limb ' num2str(i)]);
end

%%
% figure;
% plot(sum(lc_values_recentering,2))
