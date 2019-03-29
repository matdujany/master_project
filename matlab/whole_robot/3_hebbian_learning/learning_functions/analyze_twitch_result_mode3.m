function value = analyze_twitch_result_mode3(s,end_part0)

s_ss_part0 = mean(s(1:end_part0));

%the last third of part1 is used to compute the SS value:
length_part1=length(s(end_part0:end));
s_ss_part1 = mean(s(end-ceil(length_part1/3):end));

value = s_ss_part1-s_ss_part0;
end