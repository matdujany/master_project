function [frame_start,frame_stop] = get_frame_start_stop(recordID)
%GET_FRAME_START_STOP Summary of this function goes here
%   Detailed explanation goes here

frame_start = 1;
frame_stop = 10000;

switch recordID
    case 301
        frame_start = 1000;
        frame_stop = 7200;
    case 302
        frame_start = 1000;
        frame_stop = 7000;
    case 303
        frame_start = 8500;
        frame_stop = 13500;
    case 305
        frame_start = 900;
        frame_stop = 6400;
    case 307
        frame_start = 800;
        frame_stop = 6750;
    case 308
        frame_start = 1000;
        frame_stop = 6150;
    case 309
        frame_start = 1000;
        frame_stop = 6150;
    case 310
        frame_start = 9500;
        frame_stop = 14000;
    case 312
        frame_start = 1000;
        frame_stop = 7000;
    case 313
        frame_start = 500;
        frame_stop = 6000;
    case 314
        frame_start = 4500;
        frame_stop = 9800;
    case 315
        frame_start = 7500;
        frame_stop = 12250;
    case 316
        frame_start = 500;
        frame_stop = 6000;
    case 317
        frame_start = 500;
        frame_stop = 6000;
    case 319
        frame_start = 500;
        frame_stop = 6000;
    otherwise
        disp('no hardcoded frame start and stop for that motion capture recordID');
end

end

