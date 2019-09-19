clear;
close all; clc;

%here i just assume that the limbs have been properly classified (lcs to
%lcs)

addpath('../2_load_data_code');
addpath('../4_locomotion');
addpath('hinton_plot_functions');
addpath('computing_functions');


%% Load data
recordID = 105;
[data, lpdata, parms] =  load_data_processed(recordID);

weights_robotis = read_weights_robotis(recordID,parms);
weights_speed = compute_weights_speed(data,lpdata,parms);

weights_lcz = weights_robotis{parms.n_twitches}(3*[1:parms.n_lc],:);
weights_lcy = weights_robotis{parms.n_twitches}(3*[1:parms.n_lc]-1,:);
weights_speedx = weights_speed{parms.n_twitches}(1,:);

weights_lcz = fuse_weights_sym_direction(weights_lcz,parms);
weights_lcy = fuse_weights_sym_direction(weights_lcy,parms);
weights_speedx  = fuse_weights_sym_direction(weights_speedx,parms);

%%
n_limb=parms.n_lc;
switch recordID
    case 105
        %quadruped
        [limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values("X",n_limb,113);
    case 110
        %hexapod
        [limbs,limb_ids,changeDir,offset_class1] = get_hardcoded_limb_values("X",n_limb);       
end

%%
hip_motors = limb_ids(:,2);
knee_motors = limb_ids(:,1);

weights_speedx_knee = weights_speedx(1,knee_motors);
weights_lcz_hip = weights_lcz(:,hip_motors);
weights_lcz_knee = weights_lcz(:,knee_motors);
weights_lcy_hip = weights_lcy(:,hip_motors);
weights_lcy_knee = weights_lcy(:,knee_motors);

%%
% h=plot_Nz_dot_alpha_dot(weights_lcz_hip,'hip');

h=plot_Nz_dot_alpha_dot(weights_lcz_hip,'hip');
h=plot_Nz_dot_alpha_dot(weights_lcz_knee,'knee');

u_hip = zeros(n_limb);
u_knee = zeros(n_limb);

for i=1:parms.n_lc
    for j=1:n_limb
        u_hip(i,j) = -sign(weights_lcz_hip(i,i)) * weights_lcz_hip(j,i);
        u_knee(i,j)= -sign(weights_speedx_knee(i)) * weights_lcz_knee(j,i);
    end
end

h=plot_inv_map_Nz_hip_only(u_hip);
h=plot_inv_map_Nz_knee_only(u_knee);


%%

h=plot_Ny_dot_alpha_dot(weights_lcy_hip,'hip');
h=plot_Ny_dot_alpha_dot(weights_lcy_knee,'knee');

v_hip = zeros(n_limb);
v_knee = zeros(n_limb);

for i=1:parms.n_lc
    for j=1:n_limb
        v_hip(i,j) = -sign(weights_lcz_hip(i,i)) * weights_lcy_hip(j,i);
        v_knee(i,j)= -sign(weights_speedx_knee(i)) * weights_lcy_knee(j,i);
    end
end

% for i=1:n_limb
%     weights_lcy_knee_sign_corr(:,i) = weights_lcy_knee(:,i).*sign_correction_knee(i);
% end
% weights_inv_map_friction = weights_lcy_knee_sign_corr';
% h=plot_inv_map_Ny_knee_only(weights_inv_map_friction);

h=plot_inv_map_Ny_hip_only(v_hip);
h=plot_inv_map_Ny_knee_only(v_knee);

% h=plot_inv_map_Ny_hip_only(100*u_hip/58.9);
%%

print_map(u_hip,'u_hip');
print_map(u_knee,'u_knee');
print_map(v_hip,'v_hip');
print_map(v_knee,'v_knee');

function print_map(map,titleString)
n_limb =size(map,1);
fprintf(['std::vector<std::vector<float>> ' titleString '={\n']);
switch n_limb
    case 4
        fprintf('{%.3f, %.3f, %.3f, %.3f} ,\n',map');
    case 6
        fprintf('{%.3f, %.3f, %.3f, %.3f, %.3f, %.3f} ,\n',map');
    case 8
        fprintf('{%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f} ,\n',map');
end
fprintf('};\n');
fprintf('\n');

end
