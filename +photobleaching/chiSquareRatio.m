function [ chi2t, chi2ratio ] = chiSquareRatio( rawdata,trace,counterfit,levels )
%CHISQUARERATIO Calculates chi 2 value and chi 2 ratio for a trace.
% 
% Syntax:
% [chi2t,chi2ratio] = CHISQUARERATIO(rawdata,trace,counterfit,levels)
% 
% Description:
% Calculates chi 2 value for the ideal trace and the counterfit via
% summation, and then calculates their ratio.
% 
% Input:
% rawdata - a vector containing the raw trace from the Gafney file.
% trace - the ideal trace as calculated by photobleaching.stepDetection.
% counterfit - the counterfit to the ideal trace as calculated by
% photobleaching.counterFit.
% levels - a 3xN array containing step information for the trace. 1st row:
% step "height". 2nd row: starting index of step. 3rd row: ending index of
% step.
% 
% Output:
% chi2t (scalar) - calculated chi 2 value for the ideal trace.
% chi2ratio (scalar) - ratio between the chi 2 values for the ideal and
% counterfit traces.

numPoints = numel(rawdata);
if (numPoints~=numel(trace) || numPoints~=numel(counterfit))
   error('wrong # points'); 
end

inds = find(isnan(rawdata));
rawdata(inds) = [];
trace(inds) = [];
counterfit(inds) = [];
numPoints = numel(rawdata);

% Get rid of zeros in levels.
tempLevels = levels;
levels = [];
numL = 0;
for iLev = 1:size(tempLevels,2)
   if tempLevels(1,iLev)~=0
      numL = numL+1;
      levels(:,numL)=tempLevels(:,iLev); 
   end
end

% Level info.
%levelLen = levels(3,end)-levels(2,1);
numLevels = size(levels,2);
levelVars = zeros([1,numLevels]); % Variance for each level.
for iLev = 1:numLevels
   levData = rawdata(levels(2,iLev):levels(3,iLev)); 
   levelVars(iLev) = var(levData);
end

% chi2 for trace.
chi2t = calculateMe(numPoints,rawdata,trace);
% chi2 for counterfit.
chi2cf = calculateMe(numPoints,rawdata,counterfit);

% Ratio is counterfit/trace.
chi2ratio = chi2cf/chi2t;

end

% Helper function.
function chi2 = calculateMe(numPoints,rawdata,trace)

tenper = 0.1*max(trace);

% Sum over points to get chi2 value.
chi2 = 0;
for iPoint=1:numPoints
   if abs(rawdata(iPoint)-trace(iPoint))>tenper
       numerator = (rawdata(iPoint)-trace(iPoint))^2;
   else
       numerator = 0;
   end
   % Variance of this level.
   varHere = trace(iPoint);
   if varHere~=0
    chi2 = chi2 + (numerator/varHere);
   end
end

end

