function pos = phase2pos_hipknee_wrapper(phase,isHip,changeDir,params)
%PHASE2POS_HIPKNEE_WRAPPER Summary of this function goes here
%   Detailed explanation goes here
if isHip
    pos = zeros(1,length(phase));
    for i=1:length(phase)
        if cos(phase(i))>0
            pos(i) = phase2pos_oscillator(phase(i), params.amplitude_hip_deg, changeDir);
        else
            pos(i) = phase2pos_oscillator(phase(i), params.alpha*params.amplitude_hip_deg, changeDir);
        end
    end
else
    pos = phase2pos_oscillator(phase, params.amplitude_knee_deg, changeDir);
end
end