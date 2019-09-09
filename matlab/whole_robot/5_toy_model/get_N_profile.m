function [phi_obj,N_obj] = get_N_profile(total_load,n_limb)

phi_obj = linspace(0,2*pi,30);
N_obj = total_load/n_limb * (phi_obj>pi);

end
