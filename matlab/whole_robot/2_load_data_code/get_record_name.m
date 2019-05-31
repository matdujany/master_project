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
    case 100
        record_name = '2019-5-21-18_24_14';
    case 101
        record_name = '2019-5-22-13_28_51';
    case 102
        record_name = '2019-5-22-16_43_55';
    case 103
        record_name = '2019-5-23-14_15_56';
    case 104
        record_name = '2019-5-23-15_0_3';
    case 105
        record_name = '2019-5-23-16_59_45';
    case 106
        record_name = '2019-5-23-20_7_52';
    case 107
        record_name = '2019-5-29-14_45_56';
    case 108
        record_name = '2019-5-29-16_1_53';
    case 109
        record_name = '2019-5-30-12_42_55';
    case 110
        record_name = '2019-5-30-13_9_32';
    case 111
        record_name = '2019-5-31-12_53_23';
    case 112
        record_name = '2019-5-31-15_14_41';
    case 113
        record_name = '2019-5-31-16_6_47';
    case 114
        record_name = '2019-5-31-16_57_7';
    case 115
        record_name = '2019-5-31-18_13_52';
    otherwise
        disp('unknown recordId');
end

end

