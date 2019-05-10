clear; clc; close all;

addpath('../2_load_data_code');

recordID = 17;
filename = get_record_name_locomotion(recordID);
[lc_data, phi_position_data, parms_locomotion, parms] = load_data_locomotion(recordID);


%put here the parms you want to change
parms_locomotion.filter_size = 4;


file_name_after_fix=strcat("../../../../data/locomotion/",filename);
save(file_name_after_fix,'lc_data','phi_position_data','parms_locomotion','parms');
