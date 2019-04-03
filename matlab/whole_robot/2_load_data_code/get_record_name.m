function record_name = get_record_name(recordId)
%GET_RECORD_NAME Summary of this function goes here
%   Detailed explanation goes here
switch recordId
    case 1
        record_name = '2019-3-29-12_20_38';
    case 2
        record_name = '2019-3-29-13_56_43';
    case 3
        record_name = '2019-3-29-14_48_55';
    case 4
        record_name = '2019-3-29-14_59_40';
    case 5
        record_name = '2019-4-1-10_29_40';
    case 6
        record_name = '2019-4-1-10_56_16';
    case 7
        record_name = '2019-4-3-9_34_16';
    case 8
        record_name = '2019-4-3-10_12_16';
    case 9
        record_name = '2019-4-3-10_23_31';
    case 10
        record_name = '2019-4-3-10_30_12';
    case 11
        record_name = '2019-4-3-17_30_26';
    otherwise
        disp('unrecognized recordId');
end

end

