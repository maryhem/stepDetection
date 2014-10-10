function [outSig, numL, outSigma, levels] = annealingPhase(I, sigStep, nff, snr, phi)
% ANNEALINGPHASE  Annealing phase of the step detection algorithm.
%
% Syntax:
% [outSig, numL, outSigma, levels] = ANNEALINGPHASE(I, sigStep, nff, snr, phi)
%
% Description:
% Provides number of levels and updates estimates for signal to noise ratio (snr)
% and threshold (phi).
%
% Input:
%
% Output:

narginchk(5, 5);

signal = snr*nff;

sigma = signal/phi;
sigi = sigma/sigStep;

% Initialize outputs
outI = I;
numL = 0;
levels = [];

initialI = I;

% Annealing phase.
for i=1:(sigStep-1)
    [NewoutI, NewnumL, Newlevels] = photobleaching.scanningPhase(I,sigi);
    if NewnumL>0
       outI = NewoutI;
       numL = NewnumL;
       levels = Newlevels;
    end
    sigi = sigma/(sigStep-i);
    I = outI;

end

if (all(outI==initialI))
   %warning('No change in signal after processing')
end

plot(I,'k');
pause(0.01);
outSig = I;
outSigma = sigma;

end

