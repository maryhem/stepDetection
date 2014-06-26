function [ out_sig, numL, out_sigma,levels ] = annealingPhase( I, params, nff, snr, phi )
%ANNEALINGPHASE Annealing phase of the step detection algorithm.
%   Provides number of levels and updates estimates for signal to noise ratio (snr)
%   and threshold (phi).

signal = snr*nff;

sigma = signal/phi;
sigi = sigma/params.sigStep;

% Initialize outputs
outI = I;
numL = 0;
levels = [];

initialI = I;

% Annealing phase.
for i=1:(params.sigStep-1)
    [NewoutI, NewnumL, Newlevels] = scanningPhase(I,sigi);
    if NewnumL>0
       outI = NewoutI;
       numL = NewnumL;
       levels = Newlevels;
    end
    sigi = sigma/(params.sigStep-i);
    I = outI;

end

if (all(outI==initialI))
   %warning('No change in signal after processing')
end

%fprintf('Min of levels = %f at %f, max = %f at %f \n',minL,minsig,maxL,maxsig)
plot(I,'k');
pause(0.01);
%fprintf('annealing finished \n');
out_sig = I;
out_sigma = sigma;

end

