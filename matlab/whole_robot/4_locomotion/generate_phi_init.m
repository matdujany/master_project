
n_limb = 4;
n_repetitions = 5;

phi_init = 2*pi *rand(n_limb,n_repetitions);

switch n_limb
    case 4
        disp ('phi_init :'); fprintf('{%.2f, %.2f, %.2f, %.2f}\n',phi_init);
    case 6
        disp ('phi_init :'); fprintf('{%.2f, %.2f, %.2f, %.2f, %.2f, %.2f}\n',phi_init);
    case 8  
        disp ('phi_init :'); fprintf('{%.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f}\n',phi_init);
end

%%
rand_map = rand(n_limb)-1/2*ones(n_limb) ;
switch n_limb
    case 4
        disp ('rand_map :'); fprintf('{%.2f, %.2f, %.2f, %.2f}\n',rand_map);
    case 6
        disp ('rand_map :'); fprintf('{%.2f, %.2f, %.2f, %.2f, %.2f, %.2f}\n',rand_map);
    case 8  
        disp ('rand_map :'); fprintf('{%.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f}\n',rand_map);
end
