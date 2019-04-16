function subplots_all_Acc_Gyro(idx_twitch,s_IMU,parms,amp,txt_list)
FontSize = 14;
lineWidth = 1.4;

y_min = -amp;
y_max = amp;

x_patch_learning = [26 50 50 26];
y_patch_learning = [y_min y_min y_max y_max];
n_frames_theo = get_theo_number_frames(parms);

index_start_twitch = 1+n_frames_theo.per_twitch*(idx_twitch-1);


f=figure;
f.Color = 'w';
% tight_subplot(Nh, Nw, gap, marg_h, marg_w) 
[ha, pos] = tight_subplot(3,parms.n_m*2,[.01 .01],[.01 .03],[.035 .01]);
for i_sensor_IMU = 1:3
        for i_motor = 1:parms.n_m*2
        axes(ha(parms.n_m*2*(i_sensor_IMU-1)+i_motor));
        hold on;
        index_start = index_start_twitch+n_frames_theo.per_action*(i_motor-1);
        index_end = index_start + n_frames_theo.per_action-1;
        plot(s_IMU(index_start:index_end,i_sensor_IMU),'LineWidth',lineWidth);
        patch(x_patch_learning,y_patch_learning,'blue','FaceAlpha',0.1,'EdgeColor','none');
        plot([0 n_frames_theo.per_action-1],[0 0]);
        xlim([n_frames_theo.part0-10 n_frames_theo.part0+n_frames_theo.part1+10]);
        ylim([y_min y_max]);
    end    
end

step_y = -pos{1+2*parms.n_m}(2)+pos{1}(2);
y_shift = pos{end}(2)+pos{end}(4);
for i_sensor = 1:3
    y_pos = step_y*(i_sensor-1)+y_shift;
    annotation('textbox',  [0,y_pos, 0, 0],'string',txt_list{1,4-i_sensor},'FontSize',FontSize,'HorizontalAlignment','center','FitBoxToText','on','EdgeColor','none');
end

step_x = pos{2}(1)-pos{1}(1);
x_shift = pos{1}(1)+pos{1}(3)/2;
y_pos_column_title = 1.0;
for i_motor = 1:parms.n_m
    x_pos = step_x*2*(i_motor-1)+x_shift;
    annotation('textbox', [x_pos, y_pos_column_title, 0, 0],'string',['M' num2str(i_motor) '-'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');
    annotation('textbox', [x_pos+step_x, y_pos_column_title, 0, 0], 'string',['M' num2str(i_motor) '+'],'FontSize',FontSize,'FitBoxToText','on','EdgeColor','none');

end

end
