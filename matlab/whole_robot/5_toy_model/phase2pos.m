function pos = phase2pos(phase)
%PHASE2POS_OSCILLATOR Summary of this function goes here
%   Detailed explanation goes here

if sin(phase)>0
    pos = 10*sin(phase);
else
    pos = sin(phase);
end

end

