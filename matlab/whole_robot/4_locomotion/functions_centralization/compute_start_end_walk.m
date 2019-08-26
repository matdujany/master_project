function [idx_start_walk,idx_end_walk] = compute_start_end_walk(GRF,time_phi,margin_indexes)
%COMPUTE_START_END_WALK Summary of this function goes here
%   Detailed explanation goes here
total_grf = movmean(sum(GRF,2),10);
total_load = quantile(total_grf,0.95);
idx_end_walk = find(diff(total_grf > total_load/2)<0);
idx_start_walk = find(diff(total_grf > total_load/2)>0);

if total_grf(1)>total_load/2
    idx_start_walk = [1;idx_start_walk];
end
if total_grf(end)>total_load/2
    idx_end_walk = [idx_end_walk;length(total_grf)];
end
        
idx_start_walk = idx_start_walk + margin_indexes;
idx_end_walk = idx_end_walk - margin_indexes;
i=1;
while i<length(idx_start_walk)
    if idx_end_walk(i)-idx_start_walk(i)<0
        idx_end_walk(i) = [];
        idx_start_walk(i) = [];
    end
    i=i+1;
end

figure;
sgtitle('Sequence selection');

subplot(2,1,1);
hold on;
plot(total_grf);
for i=1:length(idx_start_walk)
    plot(idx_start_walk(i)*[1 1],[0 total_load],'k--');
end
for i=1:length(idx_end_walk)
    plot(idx_end_walk(i)*[1 1],[0 total_load],'k--');
end

subplot(2,1,2);

hold on;
plot(diff(time_phi));
for i=1:length(idx_start_walk)
    plot(idx_start_walk(i)*[1 1],[0 max(diff(time_phi))],'k--');
end
for i=1:length(idx_end_walk)
    plot(idx_end_walk(i)*[1 1],[0 max(diff(time_phi))],'k--');
end


end

