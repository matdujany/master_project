%% Set parameters

% % % DOCUMENTATION % % %
% The most important parameters are the ones under Mode and Serial settings.
% 
% nr_arduinos:      For correct processing of the data, this value should be 
%                   the numbers of arduino's in the daisychain during the 
%                   recording. If incorrect, parsing will go wrong.

parms = struct();

parms.nr_arduino  = 6;
parms.n_m         = 12;
parms.n_dir       = 2;

% learning parameters
parms.eta            = 10;        %learning rate
parms.duration_part0 = 500; % in ms
parms.duration_part1 = 2200; % in ms
parms.duration_part2 = 200; % in ms
parms.n_twitches     = 3;
parms.compliant_mode = 1;
parms.recentering    = 1;
parms.recentering_delay    = 1500; % in ms
parms.time_interval_twitch = 21; % in ms

parms.use_ramp_slope = 0;
parms.rampe_slope    = 1.4;         %position increment per frame

parms.use_sine_twitching = 0;
parms.ampl_sine_twitching = 12; % in degrees
parms.freq_sine_twitching = 0.5; % in Hz

parms.use_cos_twitching = 1;
parms.ampl_cos_twitching = 10; % in degrees
parms.freq_cos_twitching = 0.5; % in Hz

if parms.use_ramp_slope+parms.use_sine_twitching+parms.use_cos_twitching~=1
    disp('Pb with parms. twitching mode selected');
    return;
end

%filter
parms.use_filter = 1;
parms.add_filter_size = 4;

%IMU offset update
parms.delay_frames_update_offset = 30; %in ms
parms.nb_values_mean_update_offset = 50;
parms.gyro_gain =  0.06957;

%%manual recentering between twitches
parms.manual_recentering_duration    = 15; % in s
parms.manual_recentering_time_interval_frame    = 200; % in ms

% % % % % % % % % % % % % % % 
parms.n_lc        = parms.nr_arduino;
parms.n_ch_lc     = 3;
parms.n_useful_ch_IMU    = 6;

% Constants (should be adopted from Robotis file)
parms.sensor_data_adc_length    = 4;
parms.sensor_data_length        = 3 * parms.sensor_data_adc_length + 1;
parms.IMU_data_length           = 25; %(6 channels * 4 + 1 for timestamp)
parms.max_nr_arduino            = 6;
parms.frame_size                = 7 + parms.nr_arduino * parms.sensor_data_length + parms.IMU_data_length;
parms.offset_start_data         = 6;
parms.idx_end_data              = parms.frame_size -2;

% Checkframe settings
parms.endByte          = '55';
parms.firstStartByte   = 'FF';
parms.secondStartByte  = 'AA';
parms.frametype_data   = '01';