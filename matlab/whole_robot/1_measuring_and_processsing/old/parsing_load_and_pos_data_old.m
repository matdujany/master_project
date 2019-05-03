function lpdata = parsing_load_and_pos_data_old(pos_load_data_rec,parms)

%serial.println adds these two bytes after each print.
endcode1_println = 13;
endcode2_println = 10;

idx1 = find(pos_load_data_rec == endcode1_println);
idx2 = find(pos_load_data_rec == endcode2_println);
check = idx2-idx1 - ones(length(idx1),1);
if sum(check) ~= 0
    disp('Pb with indexes of end codes');
end

%%
current_index = 1;
pos_load_data = zeros(length(idx1),1);
for i=1:length(idx1)
    ascii_values = [pos_load_data_rec(current_index:idx1(i)-1)];
    str = char(ascii_values);
    pos_load_data(i)=str2double(str);
    current_index = idx2(i)+1;
end


%%
n_prints = 3 + parms.n_m*2; %3 (i ppart, last motor pos for learning + timestamp) 
%+ n_m * 2 (load and pos);

nb_samples = (length(pos_load_data)-1)/n_prints; %-1 because 1500 printed at the end just to confirm.
motor_position = zeros(parms.n_m,nb_samples);
motor_load = zeros(parms.n_m,nb_samples);
last_motor_timestamp = zeros(nb_samples,1);
last_motor_pos =zeros(nb_samples,1);
i_part =zeros(nb_samples,1);

for i=1:nb_samples
    for k=1:parms.n_m
        motor_position(k,i) = pos_load_data(1+2*(k-1)+n_prints*(i-1));
        motor_load(k,i) = pos_load_data(2+2*(k-1)+n_prints*(i-1));
    end
    last_motor_pos(i,1)=pos_load_data(-2 + n_prints*i);
    last_motor_timestamp(i,1)=pos_load_data(-1 + n_prints*i);
    i_part(i,1)=pos_load_data(n_prints*i);
end

addpath(genpath('../plotting_functions'));
colorlist = maxdistcolor_wrapper(parms.n_m); 
legend_list = cell(parms.n_m,1);
figure;
subplot(2,1,1);
hold on;
for k=1:parms.n_m
    plot(motor_position(k,:),'Color',colorlist(k,:));
    legend_list{k}= ['Motor ' num2str(k)];
end
legend(legend_list);
subplot(2,1,2);
hold on;
for k=1:parms.n_m
    plot(motor_load(k,:),'Color',colorlist(k,:));
end
legend(legend_list);

%figure;
%plot(i_part);

lpdata = struct();
lpdata.motor_position = motor_position;
lpdata.motor_load = motor_load;
lpdata.last_motor_pos = last_motor_pos;
lpdata.last_motor_timestamp = last_motor_timestamp;
lpdata.i_part = i_part;


end
