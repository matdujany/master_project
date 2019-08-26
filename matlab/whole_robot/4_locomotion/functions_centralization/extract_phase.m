function [extracted_phase,loc_peaks_phase] = extract_phase(signal_phase_extraction,time,parms)
%EXTRACT_PHASE Summary of this function goes here
%   Detailed explanation goes here

s_fft = signal_phase_extraction';
Ts = parms.time_interval_twitch*10^-3;                      % Sampling Interval (sec)
Fs = 1/Ts;                                                  % Sampling Frequency (Hz)
Fn = Fs/2;                                                  % Nyquist Frequency (Hz)
t = time;                             % Time Vector
L = length(t);                                              % Vector Length
FTs = fft(s_fft-mean(s_fft))/L;                             % Fourier Transform (Subtract d-c Offset)
Fv = linspace(0, 1, fix(L/2)+1)*Fn;                         % Frequency Vector
Iv = 1:length(Fv);                                          % Index Vector
[pks1,frqs1] = findpeaks(abs(FTs(Iv,1))*2, Fv, 'MinPeakHeight',0.05);

extracted_phase = mod([0:length(signal_phase_extraction)-1]*Ts*2*pi*frqs1(1),2*pi);
[peaks_phase,loc_peaks_phase] = findpeaks(extracted_phase);

figure;
sgtitle('Phase extraction');
subplot(3,1,1);
hold on;
plot(signal_phase_extraction);
plot([1 length(signal_phase_extraction)],signal_phase_extraction(1)*[1 1],'k--');
ylabel('Origin Signal for phase extraction');
subplot(3,1,2);
hold on;
plot(extracted_phase);
scatter(loc_peaks_phase, peaks_phase, 'ro');
ylabel('Extracted Phase');
subplot(3,1,3);
plot(Fv, abs(FTs(Iv,:))*2)
hold on
plot(frqs1, pks1, '^b')
hold off
grid
axis([0  Fn    ylim]);
ylabel('FFT for phase extraction');

% signal_phase_extraction = sin([1:5000]*10^-3*2*pi*2);
% z = hilbert(signal_phase_extraction); 
% inst_phase = angle(z);%inst phase



end

