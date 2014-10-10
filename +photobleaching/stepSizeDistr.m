function outMat = stepSizeDistr(numBins,accTable)
% STEPSIZEDISTR  Create an array representing the average step size for all
% observed numbers of steps.
%
% Syntax:
% outMat = STEPSIZEDISTR(numBins,accTable)
% 
% Description:
% Calculates average step size for all traces with the SAME number of
% steps. Will calculate individual averages up to numBins, and then group
% any traces with more than numBins steps into one bin.
% 
% Input:
%   numBins - desired # bins.
%   accTable - table of accepted traces.
% 
% Output:
% outMat (Nx2) - first column = # of steps, 2nd column = average step size
% for all traces with that number of steps.

% outMat consists of first col = # steps, 2nd col = average step size, for
% numBins total rows.
outMat = zeros([numBins,2]);

numTraces = height(accTable); % # of traces in accepted table.

% Loop over bins.
for iBin = 1:numBins-1
    averageMe = [];
    % Loop over accepted traces.
    for iAcc = 1:numTraces
       numSteps = accTable.numSteps(iAcc);
       numSteps = numSteps{1};
       % If numSteps is not numeric than it's 'NM1' or 'NM2' and we'll skip
       % it.
       if ~isnumeric(numSteps)
           continue;
       end
       if numSteps==iBin
          % Add the average step size for this trace to averageMe.
          averageMe(length(averageMe)+1) = accTable.avgStepSize(iAcc);
       end
    end
    outMat(iBin,1) = iBin;
    if ~isempty(averageMe)
       outMat(iBin,2) = mean(averageMe);
    else
       outMat(iBin,2) = 0; 
    end
end

% Do last # bins, tacking on any that may have more.
averageMe = [];
for iAcc = 1:numTraces
   numSteps = accTable.numSteps(iAcc);
   numSteps = numSteps{1};
   % If numSteps is not numeric than it's 'NM1' or 'NM2' and we'll skip
   % it.
   if ~isnumeric(numSteps)
       continue;
   end
   if numSteps>=numBins
       % Add the average step size for this trace to averageMe.
        averageMe(length(averageMe)+1) = accTable.avgStepSize(iAcc);
   end
end
outMat(numBins,1) = numBins;
if ~isempty(averageMe)
   outMat(numBins,2) = mean(averageMe);
else
   outMat(numBins,2) = 0; 
end

end
