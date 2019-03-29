function value = analyze_twitch_result_mode1(s_dot,end_part0)
s_dot_part0 = s_dot(1:end_part0);

s_dot_mean_part0 = mean(s_dot_part0);


s_dot_std_part0 = std(s_dot_part0)+10^-5; %sometimes the std is 0.
%s_dot_std_part0 = compute_pseudo_std(s_dot_part0)+10^-5; %sometimes the std is 0.

j = 1;
while j<=length(s_dot) && abs(s_dot(j)-s_dot_mean_part0) <3*s_dot_std_part0
    j=j+1;
end
%pb if j > length s_dot
if j>length(s_dot)
    figure;
    hold on;
    plot(s_dot);
    scatter(end_part0,s_dot(end_part0,1));
    plot([1 length(s_dot)],[s_dot_mean_part0 s_dot_mean_part0],'k--');
    plot([1 length(s_dot)],[s_dot_mean_part0-3*s_dot_std_part0 s_dot_mean_part0-3*s_dot_std_part0],'k--');
    plot([1 length(s_dot)],[s_dot_mean_part0+3*s_dot_std_part0 s_dot_mean_part0+3*s_dot_std_part0],'k--');
    hold off;
else
    direction_FP = sign(s_dot(j)-s_dot_mean_part0);
end


if direction_FP == 1
    value = max(s_dot-s_dot_mean_part0);
else
    if direction_FP == -1
        value = min(s_dot-s_dot_mean_part0);
    else
        disp('Wrong direction_FP');
        disp(direction_FP);
        value = 0;
    end
end
end

function pseudo_std = compute_pseudo_std(data)
%the microcontroller computes the std on part 0 by computing a mean on the
%first half of part 0 and then a sum squared error on the second half of
%part 0.

pseudo_mean = mean(data(1:ceil(length(data)/2)));
pseudo_std = 0;
nb_samples = 0;
for i=ceil(length(data)/2)+1:length(data)
    pseudo_std = pseudo_std + (data(i)-pseudo_mean)^2;
    nb_samples = nb_samples + 1;
end
pseudo_std = sqrt(pseudo_std/nb_samples);

end
