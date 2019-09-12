function pi_label_lists = make_2pi3_label_lists(min,max)
pi_label_lists = cell(max-min+1,1);
for i=1:max-min+1
    value = min + i - 1;
    if mod(2*value,3) > 0
       pi_label_lists{i} = [num2str(2*value) '\pi/3'];
    else
       pi_label_lists{i} = [num2str(2*value/3) '\pi'];
    end
    if value == 0
        pi_label_lists{i} = '0';
    end
end
end