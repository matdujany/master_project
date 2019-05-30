
n_limb = 6;

phi_init = 2*pi *rand(n_limb,1);

switch n_limb
    case 4
        disp ('phi_init :'); fprintf('{%.2f, %.2f, %.2f, %.2f}\n',phi_init);
    case 6
        disp ('phi_init :'); fprintf('{%.2f, %.2f, %.2f, %.2f, %.2f, %.2f}\n',phi_init);
    case 8  
        disp ('phi_init :'); fprintf('{%.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f}\n',phi_init);
end
