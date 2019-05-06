function pos = phase2pos_oscillator(phase,amp_deg,changeDir)
%PHASE2POS_OSCILLATOR Summary of this function goes here
%   Detailed explanation goes here
if changeDir
    pos = floor(512 - 3.413*amp_deg*sin(phase));
else
    pos = floor(512 + 3.413*amp_deg*sin(phase));
end
end

