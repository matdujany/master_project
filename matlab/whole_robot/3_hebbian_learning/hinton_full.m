function h=hinton_full(weights_robotis,weights_pos_robotis,parms)

% if nargin == 3
%     writeValues = 0;
% end

n_iter = parms.n_twitches;
weights = weights_robotis{n_iter};
weights_pos = weights_pos_robotis{n_iter};

%% rescaling
weights_lc = weights(1:parms.n_lc*3,:);
weights_acc = weights(parms.n_lc*3+1:parms.n_lc*3+3,:);
weights_gyro = weights(parms.n_lc*3+4:parms.n_lc*3+6,:);

weights_rescaled = [rescale(weights_pos); rescale(weights_lc); rescale(weights_acc); rescale(weights_gyro)];

[h,fig_parms]=hinton_raw(weights_rescaled);
hold on;
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize_lines = 13;
fontSize_columns = 13;

%column labels
y_shift_up = 0.75;
y_shift_bottom = 0.25;

for i=1:parms.n_m
    text(2*i-1,y_max+y_shift_up,['M' num2str(i)],'FontSize',fontSize_columns,'HorizontalAlignment','center');
    text(2*i-0.5,y_max+y_shift_bottom,'+','FontSize',fontSize_columns,'HorizontalAlignment','center');
    text(2*i-1.5,y_max+y_shift_bottom,'-','FontSize',fontSize_columns,'HorizontalAlignment','center');   
    %text(2*i-1.5,y_max+y_shift,['M' num2str(i) '-'],'FontSize',fontSize_columns,'HorizontalAlignment','center');
    %text(2*i-0.5,y_max+y_shift,['M' num2str(i) '+'],'FontSize',fontSize_columns,'HorizontalAlignment','center');
    if i<parms.n_m
        plot([2*i 2*i],[y_min y_max],'k--')
    end
end
%
%line labels motors
n_sensors = size(weights_rescaled,1);
x_shift = 0.25;
for i=1:parms.n_m
    text(x_min-x_shift,n_sensors+0.5-i,['Motor ' num2str(i)],'FontSize',fontSize_lines,'HorizontalAlignment','right');
end
plot([x_min x_max],n_sensors-parms.n_m + [0 0],'k--')

%line labels loadcells
txt_loadcell = {' X',' Y',' Z'};
for i=1:3*parms.n_lc
    text(x_min-x_shift,n_sensors-parms.n_m+0.5-i,['Loadcell ' num2str(ceil(i/3)) txt_loadcell{mod(i-1,3)+1}],'FontSize',fontSize_lines,'HorizontalAlignment','right');
end
for i=1:parms.n_lc+1
    plot([x_min x_max],n_sensors-parms.n_m-3*i + [0 0],'k--')
end

%line labels IMU
txt_IMU = {'Acc. X','Acc. Y','Acc. Z','Gyro. Roll','Gyro. Pitch','Gyro. Yaw'};
for i=1:6
    text(x_min-x_shift,n_sensors-parms.n_m-3*parms.n_lc+0.5-i,txt_IMU{i},'FontSize',fontSize_lines,'HorizontalAlignment','right');
end

xlim([x_min x_max]);
ylim([y_min y_max]);

ax=gca();
ax.Position = [0.01 0.01 1 0.95];

h.Color = 'w';
hold off;
end

function weights_rescaled = rescale(weights)
weights_rescaled = weights/(max(max(abs(weights))));
end