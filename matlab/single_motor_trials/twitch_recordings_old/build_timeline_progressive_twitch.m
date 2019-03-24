%%building timeline : not easy because the sampling time are not the same for each part :
%%writing the goal position adds about 0.3 
nb_samples_beg = floor(2000/sampling_time_static);
nb_samples_recentering = floor(1000/sampling_time_static);
nb_samples_p0 = floor(part0/sampling_time_dynamic);
nb_samples_p1 = floor(part1/sampling_time_static);
nb_samples_p2 = floor(part2/sampling_time_static);

nb_samples_emp = nb_samples_beg + (nb_samples_p0 + nb_samples_p1+nb_samples_p2)*2*n_servos*n_twitches+...
    nb_samples_recentering*n_servos*n_twitches;

time_beg = [0:nb_samples_beg-1]*sampling_time_static;
time_p0 = [0:nb_samples_p0-1]*sampling_time_dynamic;
time_p1 = [0:nb_samples_p1-1]*sampling_time_static;
time_p2 = [0:nb_samples_p2-1]*sampling_time_static;
time_recentering = [0:nb_samples_recentering-1]*sampling_time_static;

temp = concatenate_timelines(time_p0,time_p1);
time_dir = concatenate_timelines(temp, time_p2);
time_2dir = concatenate_timelines(time_dir,time_dir);
time_twitch = concatenate_timelines(time_2dir,time_recentering);

foo=0;
for m=1:n_motors
    foo = concatenate_timelines(foo,time_twitch);
end

timeline_ms = concatenate_timelines(time_beg,foo);
%timeline_ms is 1 sample longer than nb_samples_emp because of the 0 of the
%foo.
%its length is not equal to nb_samples because of the floor used.

while length(timeline_ms)<nb_samples
    timeline_ms=[timeline_ms timeline_ms(end)+sampling_time_static];
end

%%
%%just examples to show how concatenate timelines works.
timeline1= [0 1 2 3 4];
timeline2= [0 5 10];
concatenate_timelines(timeline1,timeline2);

function time = concatenate_timelines(timeline1,timeline2)
constant_microcont_delay_ms = 0.5;
time = [timeline1 timeline2+timeline1(end)+constant_microcont_delay_ms];
% i should technically add a constant time in addition to the
% timeline1(end) but we dont know how much time the microcontroller lost
% betweem
end