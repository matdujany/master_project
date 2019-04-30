function parms_struct = add_parms(parms_struct)

% parms = struct();

parms_struct.colour = {'r','b','g','b.-'};


% Number of servos (m) and sensors (s)
parms_struct.n_lc        = parms_struct.nr_arduino;
parms_struct.n_ch_lc     = 3;
parms_struct.n_useful_ch_IMU    = 6;
end