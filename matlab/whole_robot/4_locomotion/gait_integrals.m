clear; close all; clc;
addpath('fix_xticklabels');

%%

grp_a.name = 'hardcoded in phase';
grp_a.recordID_list = 226;
grp_a.first_peak_integral = 10;
grp_a.last_peak_integral = 22;

grp_b.name = 'hardcoded bipod';
grp_b.recordID_list = 207;
grp_b.first_peak_integral = 47;
grp_b.last_peak_integral = 55;

grp_c.name = 'hardcoded tripod';
grp_c.recordID_list = 184;
grp_c.first_peak_integral = 27;
grp_c.last_peak_integral = 34;

grp_d.name = 'Z loads (hips)';
grp_d.recordID_list = [199   179   180   218];
grp_d.first_peak_integral = [48    41    22    29];
grp_d.last_peak_integral = [53    49    32    37];

grp_e.name = 'Friction (knee)';
grp_e.recordID_list = [ 187   205   223   225];
grp_e.first_peak_integral = [31    36    27    26];
grp_e.last_peak_integral = [37    44    38    35];

grp_f.name = 'Both (Z hips, friction knee)';
grp_f.recordID_list = [183   181   206];
grp_f.first_peak_integral = [27    36    30];
grp_f.last_peak_integral = [34    43    38];

grp_g.name = 'Z loads (hip and knee)';
grp_g.recordID_list = 208;
grp_g.first_peak_integral = [39];
grp_g.last_peak_integral = 53;

grp_h.name = 'Z loads (knee)';
grp_h.recordID_list = 209;
grp_h.first_peak_integral = 33;
grp_h.last_peak_integral = 43;

grp_i.name = 'Z loads (-hip)';
grp_i.recordID_list =  [210   211];
grp_i.first_peak_integral = [32 39];
grp_i.last_peak_integral = [42 49];

grp_j.name = 'Z loads (-knee)';
grp_j.recordID_list =  [213];
grp_j.first_peak_integral = 51;
grp_j.last_peak_integral = 58;

grp_k.name = 'Z loads (-hip -knee)';
grp_k.recordID_list =  [215];
grp_k.first_peak_integral = 43;
grp_k.last_peak_integral = 58;

grp_l.name = 'Friction (- knee)';
grp_l.recordID_list =  [220];
grp_l.first_peak_integral = 44;
grp_l.last_peak_integral = 56;

%%
list_groups_computing = {'a','b','c','d','e','f','g','h','i','j','k','l'};

for i=1:length(list_groups_computing)
    grp_name = strcat('grp_ ',list_groups_computing{i});
    n_recordings = length(eval(strcat(grp_name,'.recordID_list')));
    for k=1:n_recordings
        recordID = eval(strcat(grp_name,'.recordID_list(',num2str(k),');'));
        first_peak_integral = eval(strcat(grp_name,'.first_peak_integral(',num2str(k),');'));
        last_peak_integral = eval(strcat(grp_name,'.last_peak_integral(',num2str(k),');'));
        [integrals_GRF_ref_squared, integrals_GRF_squared_stance, integrals_squared_GRP] = compute_gait_integrals_wrapper(recordID,...
            first_peak_integral,last_peak_integral);
        eval(strcat('grp_ ',list_groups_computing{i},'.integrals_GRF_ref_squared(',num2str(k),')=',num2str(sum(integrals_GRF_ref_squared))));
        eval(strcat('grp_ ',list_groups_computing{i},'.integrals_GRF_ref_squared_stance(',num2str(k),')=',num2str(sum(integrals_GRF_squared_stance))));
        eval(strcat('grp_ ',list_groups_computing{i},'.integrals_squared_GRP(',num2str(k),')=',num2str(sum(integrals_squared_GRP))));
    end
end

%% all plots
grp_names_selected ={'a','b','c','d','e','f','g','h','i','j','k','l'};

idx_xticks = grp2idx(grp_names_selected);
xticks_labels = cell(length(grp_names_selected),1);
f = figure;
hold on;
for i=1:length(grp_names_selected)
    grp_name = strcat('grp_ ',grp_names_selected{i});
    n_recordings = length(eval(strcat(grp_name,'.recordID_list')));
    for k=1:n_recordings
        metric = eval(strcat(grp_name,'.integrals_GRF_ref_squared_stance(',num2str(k),');'));
        scatter(idx_xticks(i), metric,'bo');
        recordID = eval(strcat(grp_name,'.recordID_list(',num2str(k),');'));
        text(idx_xticks(i),metric,num2str(recordID));
    end
    xticks_labels{i} = eval(strcat(grp_name,'.name'));
end
ylabel('Sum GRF^2 [N^2]');
xticks(idx_xticks)
xlim([idx_xticks(1) idx_xticks(end)]+0.5*[-1 1]);
xticklabels(xticks_labels)
f.Position = [ 1          41        1680         400];
fix_xticklabels();

idx_xticks = grp2idx(grp_names_selected);
xticks_labels = cell(length(grp_names_selected),1);
f = figure;
hold on;
for i=1:length(grp_names_selected)
    grp_name = strcat('grp_ ',grp_names_selected{i});
    n_recordings = length(eval(strcat(grp_name,'.recordID_list')));
    for k=1:n_recordings
        metric = eval(strcat(grp_name,'.integrals_squared_GRP(',num2str(k),');'));
        scatter(idx_xticks(i), metric,'bo');
        recordID = eval(strcat(grp_name,'.recordID_list(',num2str(k),');'));
        text(idx_xticks(i),metric,num2str(recordID));
    end
    xticks_labels{i} = eval(strcat(grp_name,'.name'));
end
ylabel('Sum GRP^2 [N^2]');
xticks(idx_xticks)
xlim([idx_xticks(1) idx_xticks(end)]+0.5*[-1 1]);
xticklabels(xticks_labels)
f.Position = [ 1          41        1680         400];
fix_xticklabels();

%% plot _ Z relevant
grp_names_selected ={'a','b','c','d','i','h','j','g'};

idx_xticks = grp2idx(grp_names_selected);
xticks_labels = cell(length(grp_names_selected),1);
f = figure;
hold on;
for i=1:length(grp_names_selected)
    grp_name = strcat('grp_ ',grp_names_selected{i});
    n_recordings = length(eval(strcat(grp_name,'.recordID_list')));
    for k=1:n_recordings
        metric = eval(strcat(grp_name,'.integrals_GRF_ref_squared_stance(',num2str(k),');'));
        scatter(idx_xticks(i), metric,'bo');
        recordID = eval(strcat(grp_name,'.recordID_list(',num2str(k),');'));
        text(idx_xticks(i),metric,num2str(recordID));
    end
    xticks_labels{i} = eval(strcat(grp_name,'.name'));
end
ylabel('Sum GRF^2 [N^2]');
xticks(idx_xticks)
xlim([idx_xticks(1) idx_xticks(end)]+0.5*[-1 1]);
xticklabels(xticks_labels)
f.Position = [ 1          41        1680         400];
fix_xticklabels();


%% plot _ friction relevant
grp_names_selected ={'a','b','c','e','l','d','i'};

idx_xticks = grp2idx(grp_names_selected);
xticks_labels = cell(length(grp_names_selected),1);
f = figure;
hold on;
for i=1:length(grp_names_selected)
    grp_name = strcat('grp_ ',grp_names_selected{i});
    n_recordings = length(eval(strcat(grp_name,'.recordID_list')));
    for k=1:n_recordings
        metric = eval(strcat(grp_name,'.integrals_squared_GRP(',num2str(k),');'));
        scatter(idx_xticks(i), metric,'bo');
        recordID = eval(strcat(grp_name,'.recordID_list(',num2str(k),');'));
        text(idx_xticks(i),metric,num2str(recordID));
    end
    xticks_labels{i} = eval(strcat(grp_name,'.name'));
end
ylabel('Sum GRP^2 [N^2]');
xticks(idx_xticks)
xlim([idx_xticks(1) idx_xticks(end)]+0.5*[-1 1]);
xticklabels(xticks_labels)
f.Position = [ 1          41        1680         400];
fix_xticklabels();