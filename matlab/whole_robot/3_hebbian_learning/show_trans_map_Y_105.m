clear; 
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('hinton_plot_functions');


%% Load data
recordID = 105;
[~, ~, parms] =  load_data_processed(recordID);

original_inv_map_Y105 = [

   -0.5640    0.6880   -0.8953    0.8687
    0.6655   -0.9331    0.8698   -0.8624
   -0.9651    1.0000   -0.9156    0.8794
    0.8163   -0.8288    0.8008   -0.7708 ];

%%
h_invmap = plot_lc_to_limb_inv_map(original_inv_map_Y105,parms);

texts = findobj(gca, 'type', 'text');
for i= [12 15 16]
    texts(i).Color = 'r';
    texts(i).FontSize = 18;
end

% 
% text(0.5,3.5,num2str(original_inv_map_Y105(1,1),'%.3f'),'FontSize',14,'HorizontalAlignment','center','Color','r');
% text(0.5,2.5,num2str(original_inv_map_Y105(2,1),'%.3f'),'FontSize',14,'HorizontalAlignment','center','Color','r');


%%

inv_map_Y105_corrected = [

   -0.873    0.875   -0.8953    0.8687
    0.9   -0.9331    0.8698   -0.8624
   -0.9651    1.0000   -0.9156    0.8794
    0.8163   -0.8288    0.8008   -0.7708 ];

h_invmap_corrected = plot_lc_to_limb_inv_map(inv_map_Y105_corrected,parms);
texts = findobj(gca, 'type', 'text');
correction_color = [0, 0.5, 0];
for i= [12 15 16]
    texts(i).Color = correction_color;
    texts(i).FontSize = 18;
end

%%
addpath('../../export_fig');
export_fig('figures_report/inv_map_Y105_bad_values.pdf',h_invmap);
export_fig('figures_report/inv_map_Y105_corrected_values.pdf',h_invmap_corrected);

