function pi_label_lists = make_pi_label_lists(min,max)
pi_label_lists = cell(max-min+1,1);
for i=1:max-min+1
    value = min + i - 1;
    pi_label_lists{i} = [num2str(value) '\pi'];
    if value == 0
        pi_label_lists{i} = '0';
    end
end
end