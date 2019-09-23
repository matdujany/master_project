function pos_phi_data = parsing_pos_phi_data_locomotion(phi_position_data,parms)
%PARSING_POS_PHI_DATA_LOCOMOTION Summary of this function goes here
%   Detailed explanation goes here
%serial.println adds these two bytes after each print.
endcode1_println = 13;
endcode2_println = 10;

idx1 = find(phi_position_data == endcode1_println);
idx2 = find(phi_position_data == endcode2_println);
if length(idx2)~=length(idx1)
    disp('Pb with lengthes of end codes');
else
    check = idx2-idx1 - ones(length(idx1),1);
    if sum(check) ~= 0
        disp('Pb with positions of end codes');
    end
end

%%


%%
%1 phi per limb, then timestamp for phi update then positions and timestamp
%for position (1 per motor)
n_prints = parms.n_limb + 1 + 2*parms.n_m ;

%method 1
current_index = 1;
all_values = zeros(length(idx1),1);
for i=1:length(idx1)
    ascii_values = [phi_position_data(current_index:idx1(i)-1)];
    str = char(ascii_values);
    all_values(i)=str2double(str);
    current_index = idx2(i)+1;
end

total_prints = (length(all_values));
n_prints = parms.n_limb + 1 + 2*parms.n_m ;

nb_samples = (length(all_values))/n_prints;
limb_phi = zeros(parms.n_limb,nb_samples);
phi_update_timestamp = zeros(1,nb_samples);
motor_position = zeros(parms.n_m,nb_samples);
motor_timestamps = zeros(parms.n_m,nb_samples);

for i=1:nb_samples
    for i_limb = 1:parms.n_limb
        limb_phi(i_limb,i) = all_values(i_limb+n_prints*(i-1));
    end
    phi_update_timestamp(1,i) = all_values(parms.n_limb+1+n_prints*(i-1));
    for k=1:parms.n_m
        motor_position(k,i) = all_values(parms.n_limb+1+2*k-1+n_prints*(i-1));
        motor_timestamps(k,i) = all_values(parms.n_limb+1+2*k+n_prints*(i-1));
    end
end

motor_timestamps = motor_timestamps - motor_timestamps(:,1);

pos_phi_data = struct();
pos_phi_data.limb_phi = limb_phi;
pos_phi_data.phi_update_timestamp = phi_update_timestamp;
pos_phi_data.motor_position = motor_position;
pos_phi_data.motor_timestamps = motor_timestamps;

end

