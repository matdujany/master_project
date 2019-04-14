function subplots_z_loadcells(idx_twitch,s_dot_lc,parms,list_motors)
%SUBPLOTS_Z_LOADCELLS Summary of this function goes here
%   Detailed explanation goes here
if nargin == 3
    list_motors = [1:2*parms.n_m];
end

n_motors = length(list_motors);

FontSize = 12;
%fontSizeTicks = 12;
lineWidth = 1.4;

x_patch_learning = [26 50 50 26];
y_min = -30;
y_max = 30;
y_patch_learning = [y_min y_min y_max y_max];
n_frames_theo = get_theo_number_frames(parms);

index_start_twitch = 1+n_frames_theo.per_twitch*(idx_twitch-1);

f=figure;
f.Color = 'w';
% tight_subplot(Nh, Nw, gap, marg_h, marg_w)
% [ha, pos] = tight_subplot(parms.n_m*2,parms.n_lc,[.01 .01],[.01 .03],[.025 .01]);
[ha, pos] = tight_subplot(parms.n_lc,n_motors,[.01 .01],[.01 .03],[.025 .01]);

for i_sensor = 1:parms.n_lc
    for i_motor_loop = 1:n_motors
        %axes(ha(parms.n_lc*(i_motor-1)+i_sensor));
        axes(ha(n_motors*(i_sensor-1)+i_motor_loop));
        hold on;
        index_start = index_start_twitch+n_frames_theo.per_action*(list_motors(i_motor_loop)-1);
        index_end = index_start + n_frames_theo.per_action-1;
        plot(s_dot_lc(index_start:index_end,3*i_sensor),'LineWidth',lineWidth);
        patch(x_patch_learning,y_patch_learning,'blue','FaceAlpha',0.1,'EdgeColor','none');
        plot([0 n_frames_theo.per_action-1],[0 0]);
        xlim([n_frames_theo.part0-10 n_frames_theo.part0+n_frames_theo.part1+10]);
        ylim([y_min y_max]);
        %             yyaxis right;
        %             %plot(data.float_value_time{1,i_sensor}(index_start:index_end,channel));
        %             plot(lpdata.motor_position(ceil(i_motor/2),index_start:index_end));
    end  
end

%%
step_y = -pos{1+n_motors}(2)+pos{1}(2);
y_shift = pos{end}(2)+pos{end}(4);
for i_sensor = 1:parms.n_lc
    y_pos = step_y*(i_sensor-1)+y_shift;
    annotation('textbox', [0.01, y_pos, 0, 0], 'string',['LC' num2str(1+parms.n_lc-i_sensor) 'Z'],'FontSize',FontSize,'HorizontalAlignment','center','FitBoxToText','on','EdgeColor','none');
end

step_x = pos{2}(1)-pos{1}(1);
x_shift = pos{1}(1)+pos{1}(3)/2;
y_pos_column_title = 1.0;
for i_motor_loop = 1:n_motors
    x_pos = step_x*(i_motor_loop-1)+x_shift;
    if mod(i_motor_loop,2) == 1
        sign = '-';
    else
        sign = '+';
    end
    annotation('textbox', [x_pos, y_pos_column_title, 0, 0], 'string',['M' num2str(ceil(list_motors(i_motor_loop)/2)) sign],'FontSize',FontSize,'HorizontalAlignment','center','FitBoxToText','on','EdgeColor','none');
end


end

