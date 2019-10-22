clear; close all; clc;

u_hip_original = [
    -0.4772    0.3235    0.1446    0.0072   -0.5414    0.3062
    0.1298   -0.1675   -0.0164   -0.3312    0.5934   -0.5247
    0.1319    0.2345   -0.2720    0.4572   -0.6665    0.0421
    0.0576   -0.4905    0.3999   -0.2214    0.0753    0.1362
   -0.6202    1.0000   -0.4976    0.1250   -0.4985    0.2910
    0.4550   -0.4316   -0.0559    0.0341    0.3647   -0.4654
    ];

u_modified = u_hip_original;
u_modified(4,1) = (u_hip_original(1,4) + u_hip_original(3,6) + u_hip_original(6,3))/3;
u_modified(4,2) = (u_hip_original(3,5) + u_hip_original(1,5) + u_hip_original(2,6))/3;
u_modified(4,3) = (u_hip_original(3,4) + u_hip_original(1,6) + u_hip_original(6,1))/3;
u_modified(4,4) = (u_hip_original(3,3) + u_hip_original(1,1) + u_hip_original(6,6))/3;
u_modified(4,5) = (u_hip_original(3,2) + u_hip_original(1,2) + u_hip_original(6,5))/3;
u_modified(4,6) = (u_hip_original(3,1) + u_hip_original(1,3) + u_hip_original(6,4))/3;

u_modified_2 = u_hip_original;
u_modified_2(4,1) = u_hip_original(1,4);
u_modified_2(4,2) = u_hip_original(3,5);
u_modified_2(4,3) = u_hip_original(3,4);
u_modified_2(4,4) = u_hip_original(3,3);
u_modified_2(4,5) = u_hip_original(3,2);
u_modified_2(4,6) = u_hip_original(3,1);
