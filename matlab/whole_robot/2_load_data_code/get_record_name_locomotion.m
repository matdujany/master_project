function record_name = get_record_name_locomotion(recordId)
%GET_RECORD_NAME Summary of this function goes here
%   Detailed explanation goes here
switch recordId
    case 1
        record_name = 'trot_2019-5-3-18_45_15';
    case 2
        record_name = 'trot_2019-5-3-19_8_43';
    case 3
        record_name = 'trot_2019-5-3-19_42_4';
    case 4
        record_name = 'tegotae_basic_2019-5-3-19_59_30';
    otherwise
        disp('unknown recordID for locomotion');
end
end
