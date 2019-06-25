% function [total_count, min_dropoff] = count_dropoffs_sub(threshold_factor,data_loadz,n_frames_theo)
% 
% mean_load_p0 = mean(data_loadz(1:n_frames_theo.part0));
% total_count = 0;
% threshold_load_value = threshold_factor*mean_load_p0;
% min_dropoff = 0;
% for i_frame = 1:n_frames_theo.part1
%     delta= data_loadz(n_frames_theo.part0+i_frame)-data_loadz(n_frames_theo.part0+i_frame-1);
%     if delta < min_dropoff
%         min_dropoff = delta;
%     end
%     if data_loadz(n_frames_theo.part0+i_frame)<threshold_load_value
%         total_count = total_count + 1;
%     end
% end
% end
% 

function [total_count, min_dropoff] = count_dropoffs_sub(threshold_factor,data_loadz,n_frames_theo)

mean_load_p0 = mean(data_loadz(1:n_frames_theo.part0));
total_count = 0;
threshold_load_value = threshold_factor*mean_load_p0;
bool_dropoff = false;
min_dropoff = 0;
for i_frame = 1:n_frames_theo.part1
    delta= data_loadz(n_frames_theo.part0+i_frame)-data_loadz(n_frames_theo.part0+i_frame-1);
    if delta < min_dropoff
        min_dropoff = delta;
    end
    if delta < - 0.5*mean_load_p0
        bool_dropoff = true;
    end
    if bool_dropoff && data_loadz(n_frames_theo.part0+i_frame)<threshold_load_value
        total_count = total_count + 1;
    end
end
end