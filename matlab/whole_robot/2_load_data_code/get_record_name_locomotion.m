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
        record_name = 'tegotae_advanced_87_X_2019-5-10-11_16_17';
    case 15
        record_name = 'tegotae_advanced_88_X_2019-5-10-11_24_4';
    case 16
        record_name = 'tegotae_advanced_88_Y_2019-5-10-11_31_41';
    case 17
        record_name = 'tegotae_advanced_88_Y_2019-5-10-13_16_59';
    case 18
        record_name = 'tegotae_advanced_88_Yaw_2019-5-10-13_30_22';
    case 19
        record_name = 'tegotae_advanced_88_X_2019-5-10-13_42_16';
    case 20
        record_name = 'tegotae_advanced_88_X_2019-5-10-13_47_46';
    case 21
        record_name = 'tegotae_advanced_94_X_2019-5-13-13_24_5';
    case 22
        record_name = 'tegotae_advanced_94_X_2019-5-13-16_43_50';
    case 23
        record_name = 'tegotae_simple_94_X_2019-5-13-17_2_56';
    case 24
        record_name = 'tegotae_simple_X_2019-5-13-17_34_9';
    case 25
        record_name = 'tegotae_advanced_94_X_2019-5-13-17_51_36';
    case 26
        record_name = 'tegotae_advanced_105_X_2019-5-23-18_8_4';
    case 27
        record_name = 'leg_amp_tegotae_simple_105_X_2019-5-28-16_3_58';
    case 28
        record_name = 'leg_amp_tegotae_advanced_105_X_2019-5-28-17_50_47';
    case 29
        record_name = 'leg_amp_tegotae_advanced_105_X_2019-5-29-11_7_51';
    case 30
        record_name = 'leg_amp_tegotae_advanced_105_X_2019-5-29-11_32_6';
    case 31
        record_name = 'tegotae_advanced_108_X_2019-5-29-18_43_57';
    case 32
        record_name = 'tegotae_simple_X_2019-5-30-15_0_32';
    case 33
        record_name = 'tegotae_simple_X_2019-5-30-15_10_55';
    case 34
        record_name = 'tegotae_advanced_110_X_2019-5-30-15_35_41';
    case 35
        record_name = 'tegotae_advanced_freq_changes_110_X_2019-5-30-16_9_36';
    case 36
        record_name = 'tegotae_advanced_freq_changes_110_X_2019-5-30-16_43_20';
    case 37
        record_name = 'tegotae_advanced_mass_added_110_X_2019-5-30-17_20_47';
    case 38
        record_name = 'tegotae_advanced_mass_added_110_X_2019-5-30-17_45_31';
    case 39
        record_name = 'tegotae_advanced_amputations_110_X_2019-5-30-18_22_0';
    case 47
        record_name = 'tegotae_advanced_110_X_2019-5-30-19_22_38';
    case 48
        record_name = 'tegotae_advanced_110_X_2019-5-30-19_26_24';
    otherwise
        disp('unknown recordID for locomotion');
end
end
