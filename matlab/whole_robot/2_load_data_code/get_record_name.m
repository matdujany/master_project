function record_name = get_record_name(recordId)
%GET_RECORD_NAME Summary of this function goes here
%   Detailed explanation goes here
switch recordId
    %17 is to show lift off with a higher amplitude without help.
    case 17
        record_name = '2019-4-4-19_5_53';
    case 79
        record_name = '2019-5-2-14_33_28';
    case 80
        record_name = '2019-5-2-15_10_5';
    case 81
        record_name = '2019-5-6-17_1_19';
    case 82
        record_name = '2019-5-6-17_59_17';
    case 83
        record_name = '2019-5-6-18_28_51';
    case 84
        record_name = '2019-5-6-18_58_32';
    case 85
        record_name = '2019-5-6-19_48_24';
    case 86
        record_name = '2019-5-7-10_4_20';
    case 87
        record_name = '2019-5-8-13_37_2';
    case 88
        record_name = '2019-5-8-18_38_2';
    case 89
        record_name = '2019-5-9-17_27_10';
    case 90
        record_name = '2019-5-10-16_18_13';
    case 91
        record_name = '2019-5-10-17_3_23';
    case 92
        record_name = '2019-5-12-16_42_23';
    case 93
        record_name = '2019-5-12-18_2_4';
    case 94
        record_name = '2019-5-12-19_33_24';
    otherwise
        disp('unknown recordId');
end

end

