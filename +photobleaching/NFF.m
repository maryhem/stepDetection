function [nff, out_snr] = NFF(idealTrace, sigma, levels, snr)
% NFF  Calculates a noise estimate and SNR for a trace.
%
% Syntax:
% [nff,out_snr] = NFF(idealTrace,sigma,levels,snr)
% 
% Description:
% Calculates differences between all detected levels. If the minimum
% difference is less than 20% of the max, threshold sigma becomes the
% average of all the diffrences. Otherwise, threshold remains unchanged.
% New NFF value is the standard deviation of the changes in the ideal trace, excluding any
% changes in the signal that exceed the threshold (where the 'steps' would
% theoretically be located).
%
% Input:
% idealTrace - vector representing the ideal trace.
% sigma - initial threshold (0 when starting out, in which case NFF is
% calculated for all changes in the ideal trace).
% levels (3xN) - array representing step info. 1st row = level 'height',
% 2nd row = level start index, 3rd row = level end index.
% snr - initial signal to noise ratio (specified at the beginning by the
% user).
%
% Output:
% nff - new noise estimate, the standard deviation of all changes in signal
% over idealTrace.
% out_snr - new signal to noise ratio, defined as threshold sigma (the
% signal) divided by nff (the noise).

narginchk(4, 4);

T = numel(idealTrace);
numPoints = T; % Will be decreased if we're excluding steps above sigma.

if ~isempty(levels)
    % Find min and max difference between levels.
    minLevels = 0;
    maxLevels = Inf;
    if size(levels,2)<2
       delLevel = abs(levels(1,1)-min(idealTrace)); 
    end
    for i=2:size(levels,2)
        delLevel = abs(levels(1,i) - levels(1,i-1));
        if delLevel<minLevels
           minLevels = delLevel; 
        elseif delLevel>maxLevels
           maxLevels = delLevel;
        end
    end

    % If min difference is less than 20% of max difference, threshold is the
    % average of all differences.
    if (minLevels/maxLevels)<0.2
        meanVec = [];
        if size(levels,2)<2
           meanVec(length(meanVec)+1) = abs(levels(1,1)-min(idealTrace)); 
        end
        for i=2:size(levels,2)
            meanVec(length(meanVec)+1) = levels(1,i)-levels(1,i-1);
        end
        sigma = abs(mean(meanVec));
    end
end

% Calculate std of delIs.
% delIVec contains values of the 'drops' between steps.
delIVec = [];
for i=1:(T-1)
   delI = abs(idealTrace(i+1)-idealTrace(i)); 
   if (delI<sigma || sigma==0)
    delIVec(length(delIVec)+1) = delI;
   end
end

% Remove any NANs.
delIVec=delIVec(~isnan(delIVec));

% New nff value is standard deev of delIVec.
nff = std(delIVec);

% Calculate new signal to noise ratio, out_snr.
if sigma==0
    out_snr = snr;
else
    out_snr = sigma/nff;
end

end

