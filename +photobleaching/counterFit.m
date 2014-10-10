function cFit = counterFit(levels, trace)
% COUNTERFIT  Calculates the 'counter-fit' for an ideal trace.
% 
% Syntax:
% cFit = COUNTERFIT(levels,trace)
%
% Description:
% Calculates a trace that would be shifted one level/flipped over the y=-x
% axis (if you'd prefer) from the original trace. So the first half-level
% would be the same, but then the counter-fit would drop down to the next
% level before the regular trace, etc. The point is to create an "opposite"
% trace to the ideal trace which can be used to compare the fit to the original data.
%
% Input:
% levels (3xN) - array of step info. Row 1 = level "height", row 2 = level
% start index, row 3 = level end index.
% trace (1xN) - vector representing the ideal trace.
%
% Output:
% cFit (1xN) - vector representing the calculated counter-fit.

narginchk(2, 2);

length = levels(3,end)-levels(2,1);
numLevels = size(levels,2);

cFit = zeros([1,length]); % Row vector

% Do initial half-level.
width = levels(3,1)-levels(2,1);
cFit(1:ceil(width/2)) = levels(1,1);
if numLevels==1
    avgGap = mean([levels(1,1),trace(end)]);
else
    avgGap = mean([levels(1,1),levels(1,2)]); % Average of 1st and 2nd levels
end
endLevelOne = levels(3,1);
cFit(ceil(width/2)+1:endLevelOne) = avgGap;
%cFit(ceil(width/2)+1:width) = avgGap;

prevWidth = levels(1,1);
index = 1+width;
for i=2:numLevels
    width = levels(3,i)-levels(2,i);
    halfWidth = ceil(width/2);
    cFit(index:index+halfWidth) = avgGap;
    % New avgGap
    if i==numLevels
        avgGap = mean([levels(1,i),trace(end)]);
    else
        avgGap = mean([levels(1,i),levels(1,i+1)]);
    end
    cFit(index+halfWidth+1:index+width) = avgGap;
    prevWidth = width;
    index = index+width+1;
end

% Get rid of 0's at the end.
zeroInd = find(cFit==0);
%cFit(zeroInd) = levels(1,end);
cFit(zeroInd) = cFit(end);

% Tack on extra values.
numBefore = levels(2,1)-1;
tackOn = zeros([1,numBefore]);
tackOn(:) = levels(1,1);
cFit = horzcat(tackOn,cFit);
numLeft = numel(trace)-numel(cFit);
tackOn = zeros([1,numLeft]);
tackOn(:) = cFit(end);
cFit = horzcat(cFit,tackOn);

% For debugging
levelVec = zeros([1,length]);
index = 1;
for i=1:numLevels
   width = levels(3,i)-levels(2,i);
   levelVec(index:index+width)=levels(1,i);
   index = index+width+1;
end

end

