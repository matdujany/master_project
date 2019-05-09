function inverse_map = get_inverse_map(parms_locomotion)
%GET_INVERSE_MAP Summary of this function goes here
%   Detailed explanation goes here

% inverse_map= [ [ 0.3606 -0.3424 0.2946 -0.2940];
%              [-0.2401 0.3333 -0.2977 0.3155];
%              [ 0.3170 -0.3175 0.3229 -0.2866];
%              [-0.2127 0.2447 -0.2821 0.2984] ];
         
inverse_map_X = [[   -0.7031    0.9588   -0.7128    0.7375];
                 [    1.0000   -0.7272    0.8582   -0.8582];
                 [   -0.4814    0.5062   -0.5660    0.6029];
                 [    0.5430   -0.5524    0.7810   -0.6307] ];
             
inverse_map_Y = [[   -0.4458    0.6427   -0.6736    0.4634];
                 [    0.9072   -0.8495    0.8136   -0.8951];
                 [   -0.9770    1.0000   -0.9524    0.9433];
                 [    0.4645   -0.6192    0.6565   -0.5372]];
             
switch parms_locomotion.categoryName{1}(end)
    case 'Y'
        inverse_map = inverse_map_Y;
    case 'X'
        inverse_map = inverse_map_X;
    otherwise
        disp('unrecognized locomotion direction');
end

end

