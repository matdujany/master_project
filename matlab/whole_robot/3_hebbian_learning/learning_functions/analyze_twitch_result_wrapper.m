function s_value_for_learning = analyze_twitch_result_wrapper(s_lc,s_dot_lc,s_IMU,pos_move,parms,flagPlot)
%return 1xparms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU values.
s_value_for_learning = zeros(1,parms.n_lc * parms.n_ch_lc + parms.n_useful_ch_IMU );

% figure;
% hold on;
% plot(s_dot_to_analyse(:,1));
% scatter(pos_peak,s_dot_to_analyse(pos_peak,1));
% hold off;

pause_duration = 2;

end_part0 = pos_move-5;
for index_sensor = 1:parms.n_lc * parms.n_ch_lc
    
    if flagPlot
    f=figure;
    subplot(1,2,1);
    hold on;
    plot(s_lc(:,index_sensor));
    plot([end_part0 end_part0],[min(s_lc(:,index_sensor)) max(s_lc(:,index_sensor))],'k--');
    hold off;
    title(strcat('Sensor ',num2str(index_sensor)));
    subplot(1,2,2);
    hold on;
    plot(s_dot_lc(:,index_sensor));
    plot([end_part0 end_part0],[min(s_dot_lc(:,index_sensor)) max(s_dot_lc(:,index_sensor))],'k--');
    title('differentiated');
    hold off;    
    pause(pause_duration);
    close(f);
    end
    
    switch parms.learning_mode
        case 1
            s_value_for_learning(1,index_sensor) = analyze_twitch_result_mode1(s_dot_lc(:,index_sensor),end_part0);
        case 2
            s_value_for_learning(1,index_sensor) = analyze_twitch_result_mode2(s_lc(:,index_sensor),s_dot_lc(:,index_sensor),end_part0);
        case 3
            s_value_for_learning(1,index_sensor) = analyze_twitch_result_mode3(s_lc(:,index_sensor),end_part0);
        otherwise
            disp('Wrong Learning mode');
    end
end

if flagPlot
f=figure;
for index_IMU = 1:parms.n_useful_ch_IMU
    subplot(2,2,index_IMU)
    hold on;
    plot(s_IMU(:,index_IMU));
    plot([end_part0 end_part0],[min(s_IMU(:,index_IMU)) max(s_IMU(:,index_IMU))],'k--');
    title(strcat('IMU channel ',num2str(index_IMU)));
    hold off;
end
pause(pause_duration*1.5);
close(f);  
end

for index_IMU = 1:parms.n_useful_ch_IMU  
    
    s_value_for_learning(1,parms.n_lc * parms.n_ch_lc+index_IMU) = ...
        analyze_twitch_result_mode1(s_IMU(:,index_IMU),end_part0);
end

end
