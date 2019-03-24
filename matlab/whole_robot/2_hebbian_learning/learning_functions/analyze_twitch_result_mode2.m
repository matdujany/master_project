function value = analyze_twitch_result_mode2(s,s_dot,end_part0)

s_ss_part0 = mean(s(1:end_part0));

%the last third of part1 is used to compute the SS value:
length_part1=length(s(end_part0:end));
s_ss_part1 = mean(s(end-int(length_part1/3):end));

direction = sign(s_ss_part1-s_ss_part0);
if direction == 1
    value = max(s_dot-s_dot_mean_part0);
else
    if direction == -1
        value = min(s_dot-s_dot_mean_part0);
    end
end
end