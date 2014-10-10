function outSteps = stepSizes(levels, numlevels, data)
% STEPSIZES  Function to calculate a vector of step sizes for a trace.
%
% Syntax:
% outSteps = STEPSIZES(levels,numlevels,data)
%
% Description:
% Calculates a vector containing all of the sizes of the steps in the ideal
% trace 'data'. One step will return the size of the drop between the one
% step and the minimum value in data, all other numbers of steps will
% return the drop between subsequent levels.
%
% Input:
% levels (3xN) - array containing step info. 1st row = step 'height', 2nd
% row = step start index, 3rd row = step end index.
% numlevels (scalar) - # of levels as calculated by
% photobleaching.stepDetection.
% data (vector) - vector representing ideal trace as calculated by
% photobleaching.stepDetection.
%
% Output:
% outSteps (vector) - a vector of the 'sizes' of all the steps, or the
% drops between levels.

narginchk(3, 3);

outSteps = [];
endVal = min(data);

% If there's ony one level, return the difference between the level and the
% end value (well, minimum value) in data.
if numlevels==1
    outSteps(length(outSteps)+1) = levels(1,1)-endVal;
end

for iLevel=2:numlevels
    stepSize = levels(1,iLevel-1)-levels(1,iLevel);
    outSteps(length(outSteps)+1) = stepSize;
end
