function integrated_speed = compute_integrated_speed(data,lpdata,parms)

[pos_start_learning,pos_end_learning] = get_start_end_learning(data,lpdata,parms,0);

integrated_speed = zeros(size(data.IMU_corrected,1),3);

for i=2:size(data.IMU_corrected,1)
    for channel=1:3
        if abs(data.IMU_corrected(i,channel))>65
            disp(['IMU corrected value channel ' num2str(channel) ' sample ' num2str(i) ' has extreme value ' num2str(data.IMU_corrected(i,channel))]);
            disp(['This value is changed to the previous one ' num2str(data.IMU_corrected(i-1,channel))]);
            data.IMU_corrected(i,channel) = data.IMU_corrected(i-1,channel);
        end
    end
end

data_IMU_filtered = myfilter(data.IMU_corrected,2+parms.add_filter_size);
for i=1:length(pos_start_learning)
    for k=pos_start_learning(i):pos_end_learning(i)
        %integrated speed here is in mm/s because
        %parms.time_interval_twitch is in ms.
        integrated_speed(k,:) = integrated_speed(k-1,:)+data_IMU_filtered(k,1:3)*(9.81/256)*parms.time_interval_twitch;
    end
end

end