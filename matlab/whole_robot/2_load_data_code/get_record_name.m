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
    case 12
        record_name = '2019-4-4-11_42_52';
    case 13
        record_name = '2019-4-4-13_43_50';
    case 14
        record_name = '2019-4-4-16_16_36';
    case 15
        record_name = '2019-4-4-16_28_36';
    case 16
        record_name = '2019-4-4-18_36_53';
    case 17
        record_name = '2019-4-4-19_5_53';
    case 18
        record_name = '2019-4-4-19_18_24';
    case 19
        record_name = '2019-4-5-9_47_59';
    case 20
        record_name = '2019-4-5-19_11_51';
    case 21
        record_name = '2019-4-8-13_0_49';
    case 22
        record_name = '2019-4-8-13_13_38';
    case 23
        record_name = '2019-4-8-17_54_0';
    otherwise
        disp('unrecognized recordId');
end

end

