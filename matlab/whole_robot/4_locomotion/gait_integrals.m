% clear; close all; clc;
addpath('fix_xticklabels');

%%
name_list = {'hardcoded in phase','hardcoded bipod', 'hardcoded tripod'...
    'Z loads (hips)','Friction (knee)','Both (Z hips, friction knee)',...
    'Z loads (hip and knee)', 'Z loads (knee)','Z loads (-hip)','Z loads (-knee)','Z loads (-hip -knee)'...
    'Friction (- knee)'};

recordID_list = [226; 207; 184; 199; 183; 181; 206; 187; 205; 179; 208; 180; 209; 210; 211; 213; 215; 218; 220; 223; 225];
first_peak_integral = [10; 47; 27; 48; 27; 36; 30; 31; 36; 41; 39; 22; 33; 32; 39; 51; 43; 29; 44; 27; 26];
last_peak_integral = [20; 55; 34; 53; 34; 43; 38; 37; 44; 49; 53; 32; 43; 42; 49; 58; 58; 37; 56; 38; 35];
n_limb = 6;
code_names = [1  2     3     4     6     6     6     5     5     4     7     4     8     9     9    10    11     4    12     5     5];

n_records = length(recordID_list);
integrals_GRF_ref_squared = zeros(n_records,n_limb);
integrals_squared_GRP = zeros(n_records,n_limb);

for i=1:n_records
    [integrals_GRF_ref_squared(i,:), integrals_squared_GRP(i,:)] = compute_gait_integrals_wrapper(recordID_list(i),...
        first_peak_integral(i),last_peak_integral(i));
end

%%
unique_code_names = unique(code_names);

f_GRF = figure;
hold on;
scatter(code_names, sum(integrals_GRF_ref_squared,2));
text(code_names,sum(integrals_GRF_ref_squared,2),num2str(recordID_list));
ylabel('Sum GRF^2 [N^2]');
xticks(unique_code_names)
xlim([unique_code_names(1) unique_code_names(end)]+0.5*[-1 1]);
xticklabels(name_list(unique_code_names))
f_GRF.Position = [ 1          41        1680         400];
fix_xticklabels();

f_GRP=figure;
hold on;
scatter(code_names, sum(integrals_squared_GRP,2));
text(code_names,sum(integrals_squared_GRP,2),num2str(recordID_list));
ylabel('Sum GRP^2 [N^2]');
xticks(unique_code_names)
xlim([unique_code_names(1) unique_code_names(end)]+0.5*[-1 1]);
xticklabels(name_list(unique_code_names))
f_GRP.Position = [ 1          41        1680         400];
fix_xticklabels();


% function f=plot_integrals(code_names_selected,integrals)
% 
% indexes_
% 
% idx = find(code_names == code_names_selected);
% metrics =  sum(integrals(idx,:),2);
% f = figure;
% hold on;
% scatter(code_names(idx), metrics);
% text(code_names(idx),metrics,num2str(recordID_list((idx))));
% ylabel('Sum GRF^2 [N^2]');
% xticks(code_names_selected)
% xlim([unique_code_names(1) unique_code_names(end)]+0.5*[-1 1]);
% xticklabels(name_list(unique_code_names))
% f.Position = [ 1          41        1680         400];
% fix_xticklabels();
% 
% end