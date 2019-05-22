function theoretical_traj = compute_theoretical_traj_wrapper(i_dir,parms)

n_frames_theo = get_theo_number_frames(parms);
if isfield(parms,'step_ampl')
    theoretical_traj = compute_theoretical_traj(i_dir,parms.step_ampl,n_frames_theo.part0,n_frames_theo.part1);
else
    theoretical_traj = compute_theoretical_traj_ramp(i_dir,parms.rampe_slope,n_frames_theo.part0,n_frames_theo.part1);
end

end

function theoretical_traj = compute_theoretical_traj(i_dir,step_ampl,n_frames_part0,n_frames_part1)
% ampl_step_pos = floor(parms.step_ampl*3.413);
ampl_step_pos = floor(step_ampl*3.413);

theoretical_traj = 512*ones(1,n_frames_part0);
signs = [-1;1];
for i=1:n_frames_part1
    theoretical_traj(1,n_frames_part0+i) = 512 +signs(i_dir)*floor(ampl_step_pos*i/n_frames_part1);
end
% for i=1:n_frames_theo.part2
%     last_motor_pos = lpdata.motor_position(i_motor,index_start_motor+n_frames_theo.part0+n_frames_theo.part1+i-1);
%     theoretical_traj(1,n_frames_theo.part0+n_frames_theo.part1+i) = ...
%         512 + floor((last_motor_pos-512)*(1-i/n_frames_theo.part2));
% end
end

function theoretical_traj = compute_theoretical_traj_ramp(i_dir,slope,n_frames_part0,n_frames_part1)

theoretical_traj = 512*ones(1,n_frames_part0);
signs = [-1;1];
for i=1:n_frames_part1
    theoretical_traj(1,n_frames_part0+i) = 512 +floor(signs(i_dir)*slope*i);
end
end