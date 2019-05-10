function [inverse_map,sigma_advanced] = get_inverse_map(parms_locomotion)
%GET_INVERSE_MAP Summary of this function goes here
%   Detailed explanation goes here

% inverse_map= [ [ 0.3606 -0.3424 0.2946 -0.2940];
%              [-0.2401 0.3333 -0.2977 0.3155];
%              [ 0.3170 -0.3175 0.3229 -0.2866];
%              [-0.2127 0.2447 -0.2821 0.2984] ];

sigma_advanced_X_86 = 0.12;
inverse_map_X_86 = [
[   -0.7031    0.9588   -0.7128    0.7375];
[    1.0000   -0.7272    0.8582   -0.8582];
[   -0.4814    0.5062   -0.5660    0.6029];
[    0.5430   -0.5524    0.7810   -0.6307] 
];

sigma_advanced_Y_86 = 0.12;           
inverse_map_Y_86 = [
[   -0.4458    0.6427   -0.6736    0.4634];
[    0.9072   -0.8495    0.8136   -0.8951];
[   -0.9770    1.0000   -0.9524    0.9433];
[    0.4645   -0.6192    0.6565   -0.5372]
];

sigma_advanced_X_87  = 0.12;
inverse_map_X_87 = [
[-0.722, 0.790, -0.589, 0.628];
[0.858, -0.668, 0.801, -0.749];
[-0.801, 0.752, -0.734, 0.976];
[0.779, -0.784, 1.000, -0.771] 
 ];
 
sigma_advanced_Y_87  = 0.12;
inverse_map_Y_87 = [
[-0.635, 0.825,-0.779, 0.590];
[ 0.941,-0.844, 0.853,-0.970];
[-0.856, 0.716,-0.767, 0.872];
[ 0.678,-1.000, 0.926,-0.763] 
];

sigma_advanced_X_88  = 0.11;
inverse_map_X_88 = [
[-0.836, 0.832, -0.647, 0.701] ,
[0.877, -0.797, 0.879, -0.890] ,
[-0.820, 0.823, -0.868, 0.896] ,
[0.786, -0.789, 1.000, -0.948]
 ];

sigma_advanced_Y_88  = 0.13;
inverse_map_Y_88 = [
[-0.558, 0.806, -0.790, 0.609] ,
[0.914, -0.783, 0.736, -0.854] ,
[-1.000, 0.891, -0.889, 0.927] ,
[0.685, -0.877, 0.872, -0.755]
];

sigma_advanced_Yaw_88  = 0.13;
inverse_map_Yaw_88 = [ 
[-0.558, 0.806, -0.790, 0.609] ,
[0.914, -0.783, 0.736, -0.854] ,
[-1.000, 0.891, -0.889, 0.927] ,
[0.685, -0.877, 0.872, -0.755]
];

sigma_advanced_X_89  = 0.13;
inverse_map_X_89 = [
[-0.930, 0.606, 0.125, -0.544, 0.259, 0.541] ,
[0.633, -0.563, 0.389, 0.303, -0.494, -0.050] ,
[-0.103, 0.363, -0.586, 0.322, -0.007, 0.133] ,
[-0.491, 0.121, 0.655, -0.834, 0.543, 0.024] ,
[0.227, -0.408, 0.071, 0.492, -0.560, 0.322] ,
[0.440, 0.034, 0.191, -0.087, 0.599, -1.000]
 ];
             
switch parms_locomotion.direction
    case "X"
        sigma_advanced = eval(strcat("sigma_advanced_X_",num2str(parms_locomotion.id_map_used)));
        inverse_map = eval(strcat("inverse_map_X_",num2str(parms_locomotion.id_map_used)));
    case "Y"
        sigma_advanced = eval(strcat("sigma_advanced_Y_",num2str(parms_locomotion.id_map_used)));
        inverse_map = eval(strcat("inverse_map_Y_",num2str(parms_locomotion.id_map_used)));
    case "Yaw"
        sigma_advanced = eval(strcat("sigma_advanced_Yaw_",num2str(parms_locomotion.id_map_used)));
        inverse_map = eval(strcat("inverse_map_Yaw_",num2str(parms_locomotion.id_map_used)));
    otherwise
        disp('unknown direction for inverse map');
end

end

