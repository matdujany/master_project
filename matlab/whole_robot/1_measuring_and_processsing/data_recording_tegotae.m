clear; clc; close all;

%% Parameters

set_parms;
parms_locomotion.recordingDuration = 30;
parms_locomotion.frequency = 0.5;
parms_locomotion.amplitude_class1_deg = 20;
parms_locomotion.amplitude_class2_deg = 20;
parms_locomotion.alpha = 0.2;
parms_locomotion.sigma_s = 0.3;

parms_locomotion.id_map_used = 88;
parms_locomotion.turning = false;
parms_locomotion.direction = "X"; %"X" "Y" or "Yaw"

parms_locomotion.use_filter = 1;
parms_locomotion.filter_size = 4;

parms_locomotion.categoryName = strcat("tegotae_advanced_",num2str(parms_locomotion.id_map_used),"_",parms_locomotion.direction);

%% Main
time_vec   = clock;
time_stamp = strcat(num2str(time_vec(1)),"-",num2str(time_vec(2)),"-",num2str(time_vec(3)),"-",num2str(time_vec(4)),"_",num2str(time_vec(5)),"_",num2str(round(time_vec(6))));
disp(time_stamp);

poolobj= parpool('local',2);
spmd(2)
    if labindex == 1
        %daisychain (Serial2), blue cable, blue FTDI
        COMportID = 10;
        bufferSize = 5000000; %check : size this buffer
        BaudRate = 500*10^3;
    else
        %lpdata (Serial3), yellow cable, red FTDI
        COMportID = 9;
        bufferSize = 5000000; %check : size this buffer
        BaudRate = 2*10^6;
    end
    s=serial(strcat('COM',num2str(COMportID)),'BaudRate',BaudRate);
    s.InputBufferSize = bufferSize;
    s.Timeout = parms_locomotion.recordingDuration+30; %in seconds
    flushinput(s);
    fprintf("\nGathering data...\n");
    fopen(s);
    out = fread(s);
    fclose(s);
    delete(s);
end
lc_data = out{1};
phi_position_data = out{2};
delete(poolobj);
%%
file_name_data = strcat("../../../../data/locomotion/",parms_locomotion.categoryName,"_",time_stamp);
fprintf("Writing data to file: %s.mat\n", file_name_data);
save(file_name_data,'lc_data','phi_position_data','parms_locomotion','parms');

