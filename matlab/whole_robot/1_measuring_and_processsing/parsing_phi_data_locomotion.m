function pos_phi_data = parsing_phi_data_locomotion(phi_position_data,parms)
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
        disp('Pb with indexes of end codes');
    end
end

%%
current_index = 1;
all_values = zeros(length(idx1),1);
for i=1:length(idx1)
    ascii_values = [phi_position_data(current_index:idx1(i)-1)];
    str = char(ascii_values);
    all_values(i)=str2double(str);
    current_index = idx2(i)+1;
end

%for recordID 27
% all_values(1:21) = [];


%%
%1 phi per limb, then timestamp for phi update
n_prints = parms.n_limb + 1;

nb_samples = (length(all_values))/n_prints;
limb_phi = zeros(parms.n_limb,nb_samples);
phi_update_timestamp = zeros(1,nb_samples);

for i=1:nb_samples
    for i_limb = 1:parms.n_limb
        limb_phi(i_limb,i) = all_values(i_limb+n_prints*(i-1));
    end
    phi_update_timestamp(1,i) = all_values(parms.n_limb+1+n_prints*(i-1));
end


pos_phi_data = struct();
pos_phi_data.limb_phi = limb_phi;
pos_phi_data.phi_update_timestamp = phi_update_timestamp;

end
