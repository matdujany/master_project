
n_limb = 6;
total_load = 19;

phi_test = linspace(00,2*pi,50)';
[profile_spline,phi_grid,GRF_grid] = load_profile_N_phi(108,3);

figure;
hold on;
plot(phi_test,estimate_GRF_from_profile(phi_test,total_load,n_limb));
plot(phi_test,ppval(profile_spline,phi_test));
xticks(pi/2*[0:4]);
xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
xlabel('\phi Limb [rad]');
xlim([0 2*pi]);
ylabel('GRF [N]');