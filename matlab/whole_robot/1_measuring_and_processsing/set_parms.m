%% Set parameters

% % % DOCUMENTATION % % %
% The most important parameters are the ones under Mode and Serial settings.
% 
% print_figures:    Do you want to save the figures? A value of 1 results in
%                   saving the figures whereas in case of a value of 0 no 
%                   figures are saved.
% 
% nr_arduinos:      For correct processing of the data, this value should be 
%                   the numbers of arduino's in the daisychain during the 
%                   recording. If incorrect, parsing will go wrong.


addpath('../data');
parms = struct();

parms.nr_arduino  = 4;
parms.n_m         = 8;
parms.n_dir       = 2;

% Mode settings
parms.print_figures  = 0;
parms.processed_data_save = 1;

% learning parameters
parms.time_interval_twitch = 36; % in ms

parms.step_ampl      = 5;       %in deg
parms.eta            = 1;        %learning rate
parms.duration_part0 = 500; % in ms
parms.duration_part1 = 500; % in ms
parms.duration_part2 = 500; % in ms
parms.n_twitches     = 5;
parms.compliant_mode = 0;
parms.recentering    = 0;

% % % % % % % % % % % % % % % 

% Constants (should be adopted from Robotis file)
parms.sensor_data_adc_length    = 4;
parms.sensor_data_length        = 3 * parms.sensor_data_adc_length + 1;
parms.IMU_data_length           = 25;
parms.max_nr_arduino            = 6;
parms.frame_size                = 7 + parms.nr_arduino * parms.sensor_data_length + parms.IMU_data_length;
parms.offset_start_data         = 6;
parms.idx_end_data              = parms.frame_size -2;

% Checkframe settings
parms.endByte          = '55';
parms.firstStartByte   = 'FF';
parms.secondStartByte  = 'AA';
