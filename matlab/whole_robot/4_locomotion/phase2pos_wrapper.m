function pos = phase2pos_wrapper(phase,isClass2,changeDir,params)
%PHASE2POS_HIPKNEE_WRAPPER Summary of this function goes here
%   Detailed explanation goes here
if isClass2
    pos = zeros(1,length(phase));
    for i=1:length(phase)
        if sin(phase(i))>0
            pos(i) = phase2pos_oscillator(phase(i), params.amplitude_class2_deg, changeDir);
        else
            pos(i) = phase2pos_oscillator(phase(i), params.alpha*params.amplitude_class2_deg, changeDir);
        end
    end
else
%     pos = phase2pos_oscillator(phase, params.amplitude_knee_deg, changeDir);
     pos = phase2pos_oscillator(phase, params.amplitude_class1_deg, changeDir);
end
end