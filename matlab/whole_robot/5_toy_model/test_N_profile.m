
n_limb = 6;
total_load = 19;

phi_test = linspace(-pi,3*pi,50)';
figure;
plot(phi_test,estimate_GRF_from_profile(phi_test,total_load,n_limb));
xticks(pi/2*[0:4]);
xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
xlabel('\phi Limb [rad]');
xlim([0 2*pi]);
ylabel('GRF [N]');