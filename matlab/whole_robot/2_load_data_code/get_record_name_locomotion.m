function record_name = get_record_name_locomotion(recordId)
%GET_RECORD_NAME Summary of this function goes here
%   Detailed explanation goes here
switch recordId
    case 1
        record_name = 'trot_2019-5-5-18_6_23';
    case 2
        record_name = 'basic_tegotae_2019-5-5-20_1_38';
    case 3
        record_name = 'tegotae_simple_turning_2019-5-5-20_21_9';
    case 4
        record_name = 'trot_air_2019-5-5-20_30_45';
    case 5
        record_name = 'lc3_test_2019-5-6-13_16_8';
    case 6
        record_name = 'trot_2019-5-6-13_32_41';
    case 7
        record_name = 'tegotae_advanced_2019-5-6-13_46_43';
    case 8
        record_name = 'tegotae_simple_2019-5-6-14_41_40';
    case 9
        record_name = 'tegotae_advanced_2019-5-6-14_51_40';
    case 10
        record_name = 'tegotae_advanced_Y_2019-5-7-17_43_46';
    case 11
        record_name = 'tegotae_advanced_X_2019-5-8-10_32_5';
    case 12
        record_name = 'tegotae_advanced_Y_2019-5-8-11_9_54';
    case 13
        record_name = 'tegotae_advanced_Y_2019-5-8-14_9_36';
    case 14
        record_name = 'tegotae_advanced_X_2019-5-8-14_35_1';
    otherwise
        disp('unknown recordID for locomotion');
end
end
