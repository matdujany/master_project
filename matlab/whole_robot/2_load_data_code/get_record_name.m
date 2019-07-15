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
    case 116
        record_name = '2019-6-2-14_55_40';
    case 117
        record_name = '2019-6-2-16_17_22';
    case 118
        record_name = '2019-6-3-18_30_42';
    case 119
        record_name = '2019-6-4-10_12_41';
    case 120
        record_name = '2019-6-4-13_31_51';
    case 121
        record_name = '2019-6-4-14_13_7';
    case 122
        record_name = '2019-6-4-14_34_35';
    case 123
        record_name = '2019-6-4-17_13_26';
    case 124
        record_name = '2019-6-5-15_42_53';
    case 125
        record_name = '2019-6-6-14_3_4';
    case 126
        record_name = '2019-6-6-14_49_15';
    case 127
        record_name = '2019-6-6-15_9_58';
    case 128
        record_name = '2019-6-8-13_54_30';
    case 129
        record_name = '2019-6-8-14_29_57';
    case 130
        record_name = '2019-6-8-15_58_30';
    case 131
        record_name = '2019-6-8-16_59_34';
    case 132
        record_name = '2019-6-8-17_26_4';
    case 133
        record_name = '2019-6-8-18_7_49';
    case 134
        record_name = '2019-6-26-17_12_7';
    case 135
        record_name = '2019-6-30-17_34_32';
    case 136
        record_name = '2019-6-30-18_8_28';
    case 137
        record_name = '2019-7-1-10_52_56';
    case 138
        record_name = '2019-7-3-11_46_22';
    case 139
        record_name = '2019-7-4-8_59_58';
    case 140
        record_name = '2019-7-4-9_28_45';
    case 141
        record_name = '2019-7-4-13_13_50';
    case 142
        record_name = '2019-7-12-11_40_52';
    case 143
        record_name = '2019-7-12-13_6_6';
    case 200
        record_name = '2019-7-15-15_40_16';
    case 201
        record_name = '2019-7-15-19_19_16';
    otherwise
        disp('unknown recordId');
end

end

