function take_name = get_take_name(recordId)
%TAKE_NAME Summary of this function goes here
%   Detailed explanation goes here
switch recordId
    case 301
        take_name = 'Take 2019-10-24 04.31.49 PM.csv';
    case 302
        take_name = 'Take 2019-10-24 05.37.28 PM.csv';
    case 303
        take_name = 'Take 2019-10-25 01.59.44 PM.csv';
    case 304
        take_name = 'Take 2019-10-25 02.17.03 PM.csv';
    case 305
        take_name = 'Take 2019-10-25 02.35.35 PM.csv';    
    case 306
        take_name = 'Take 2019-10-25 02.49.24 PM.csv';
    case 307
        take_name = 'Take 2019-10-25 03.10.41 PM.csv';
    case 308
        take_name = 'Take 2019-10-25 03.28.07 PM.csv';    
    case 309
        take_name = 'Take 2019-10-25 03.34.03 PM.csv';
    case 310
        take_name = 'Take 2019-10-25 03.45.06 PM.csv';        
    case 311
        take_name = 'Take 2019-10-25 03.52.55 PM.csv';        
    case 312
        take_name = 'Take 2019-10-25 04.46.50 PM.csv';        
    case 313
        take_name = 'Take 2019-10-25 04.50.34 PM.csv';        
    case 314
        take_name = 'Take 2019-10-25 04.56.42 PM.csv';        
    case 315
        take_name = 'Take 2019-10-25 06.19.39 PM.csv';        
    case 316
        take_name = 'Take 2019-10-25 06.28.23 PM.csv';        
    case 317
        take_name = 'Take 2019-10-25 06.32.16 PM.csv';        
    case 318
        take_name = 'Take 2019-10-25 06.39.26 PM.csv';        
    case 319
        take_name = 'Take 2019-10-25 06.50.14 PM.csv';        
    
        
    otherwise
        disp('unknown recordId');
end

end

