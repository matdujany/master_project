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
    otherwise
        disp('unrecognized recordId');
end

end

