function [outAcc,outRej,bestTraceID] = traceRejection(rawdata, stepTable, params)
% TRACEREJECTION  Test traces by several criteria, reject the ones that don't meet these criteria.
%
% Syntax:
% [outAcc,outRej,bestTraceID] = TRACEREJECTION(rawdata,stepTable,params)
%
% Description:
% Calculates chi square and chi square ratio for each trace, and then
% performs several tests:
% 1. SNR test - reject any trace with final SNR < minimum SNR.
% 2. Chi square ratio test - reject any trace with chi square ratio < 1.
% 3. Maximum allowable step amplitude test - reject any trace that has ANY
% steps larger than a fixed number times the average size step for that
% trace.
% Finds the 'best' trace for each number of steps (order: SNR, chi 2 ratio,
% chi 2 value).
% Finally, looks through rejected traces and labels them as 'NM1' or 'NM2'
% if necessary.
%
% Input:
%   rawdata = 1 row for each trace, unprocessed.
%   stepTable = output table from stepDetection, one row for each trace. Includes:
%       stepTable.numSteps
%       stepTable.avgStepSize
%       stepTable.stdStepSize
%       stepTable.idealTrace
%       stepTable.stepInfo
%       stepTable.finalSNR
%       stepTable.id
%   params = parameters for trace rejection. Includes:
%       params.minsnr (scalar) - minimum (final) signal to noise ratio for a trace to pass.
%       params.indeter (scalar) - This value times overall average step
%       size determines the threshold for indeterminate traces.
%       params.maxstepsize (scalar) - This value times the average step
%       size for a trace determines the maximum allowed size for any step.
%
% Output:
%   outAcc = table for accepted traces, one row for each trace. Includes:
%       outAcc.id
%       outAcc.numSteps
%       outAcc.finalSNR
%       outAcc.chiSquare
%       outAcc.chiSquareRatio
%       outAcc.avgStepSize
%       outAcc.stdStepSize
%       outAcc.idealTrace
%   outRej = table for rejected traces, one row for each trace. Includes:
%       outRej.id
%       outRej.reasonRej
%       outRej.numSteps
%       outRej.finalSNR
%       outRej.chiSquare
%       outRej.chiSquareRatio
%       outRej.avgStepSize
%       outRej.stdStepSize
%       outRej.idealTrace
%   bestTraceID = Nx2 array where the first column is the number of steps,
%   and the second column is the ID of the 'best' trace for that number of
%   steps (order: SNR, chi 2 ratio, chi 2 value).

narginchk(3, 3);

outAcc = table;
outRej = table;

% If there's no data, return basic out values.
if isempty(stepTable)
    return;
end

numTraces = height(stepTable);
numRejected = 0;

% Use to list IDs already rejected.
idsRejected = []; 


%% Calculate chi square and chi square ratio.
% Before doing any rejections, add the fields 'chiSquare' and
% 'chiSquareRatio' to each trace in stepTable.

% These vectors will be used later to find the best traces.
chi2ratioVec = [];
chi2Vec = [];

for iTrace=1:numTraces
   % Calculate the counterfit to the trace from the stepInfo and
   % idealTrace.
   stepInfo = stepTable.stepInfo(iTrace);
   stepInfo = stepInfo{1};
   idealTrace = stepTable.idealTrace(iTrace,:);
   cFit = photobleaching.counterFit(stepInfo,idealTrace); 
   % Fix sizing between counterfit and ideal trace.
   if length(cFit)~=length(idealTrace)
       rightLength = length(idealTrace);
       cFit=cFit(1:rightLength);
   end
   % Calculate the chi square value of the ideal trace and the chi square
   % ratio betwen the ideal trace and the counterfit.
   [chi2fit,csr] = photobleaching.chiSquareRatio(rawdata(iTrace,:),idealTrace,cFit,stepInfo);
   % Add these values to stepTable.
   stepTable.chiSquare(iTrace) = chi2fit;
   stepTable.chiSquareRatio(iTrace) = csr;
   % Add these values to our chi2/chi2ratio vectors.
   chi2Vec(length(chi2Vec)+1) = chi2fit;
   chi2ratioVec(length(chi2ratioVec)+1) = csr;
end


%% SNR test.

% Each trace has a value in stepTable for its final SNR.
% Reject if final SNR is less than params.minsnr.
for iTrace=1:numTraces
    % Get SNR from stepTable.
    outSNR = stepTable.finalSNR(iTrace);
    % If final SNR is too small, reject the trace.
    if outSNR<params.minsnr
      % Since this is the first test, no need to check if this trace was
      % already rejected.
      numRejected = numRejected+1;
      % Add this trace out outRej.
      traceID = stepTable.id(iTrace); % This should technically be the same # as iTrace.
      % Add this ID# to those already rejected.
      idsRejected(length(idsRejected)+1) = traceID;  
      % Build table to add to outRej.
      rejTable = stepTable(iTrace,:);
      % Grab numSteps, we're going to replace it with a cell.
      numSteps = stepTable.numSteps(iTrace);
      % Get rid of variables numSteps, stepSizes, and stepInfo.
      rejTable(:,{'numSteps','stepSizes','stepInfo'}) = [];
      % Re-add numSteps as a cell.
      rejTable.numSteps = {numSteps};
      % Add the variable reasonRej.
      rejTable.reasonRej = {'snr'};
      % Add rejTable to outRej.
      outRej = [outRej;rejTable];
    end
end


%% Chi-squared ratio test.

% Reject any trace if the chi square ratio is less than 1.
for iTrace=1:numTraces
   csr = stepTable.chiSquareRatio(iTrace);
   % If chi squared ratio is <1, reject the fit.
   if csr<1
      alreadyRej = false;
       for iRej = 1:length(idsRejected)
           if idsRejected(iRej)==iTrace
               alreadyRej = true;
           end
       end
       if ~alreadyRej
          numRejected = numRejected+1;
          idsRejected(length(idsRejected)+1) = stepTable.id(iTrace); % Add this ID# to those already rejected.
          % Build table to add to outRej.
          rejTable = stepTable(iTrace,:);
          % Grab numSteps, we're going to replace it with a cell.
           numSteps = stepTable.numSteps(iTrace);
          % Get rid of variables numSteps, stepSizes, and stepInfo.
          rejTable(:,{'numSteps','stepSizes','stepInfo'}) = [];
          % Re-add numSteps as a cell.
          rejTable.numSteps = {numSteps};
          % Add the variable reasonRej.
          rejTable.reasonRej = {'csr'};
          % Add rejTable to outRej.
          outRej = [outRej;rejTable];
       end
   end
end


%% Maximum allowable step amplitude test.

% If any trace contains one or more steps that exceed params.maxstepsize
% times its average step size, reject the trace.
for iTrace=1:numTraces
    % Get stepSizes and avgStepSize for this trace from stepTable.
    avgStepSize = stepTable.avgStepSize(iTrace);
    stepSizes = stepTable.stepSizes(iTrace);
    stepSizes = stepSizes{1};
    % Calculate the maximum allowable step size.
    allowable = params.maxstepsize*avgStepSize;
    % Reject if any step is > params.maxstepsize # of average steps.
    for iStep=1:length(stepSizes)
        if stepSizes(iStep)>allowable
           alreadyRej = false;
           for iRej = 1:length(idsRejected)
               if idsRejected(iRej)==iTrace
                   alreadyRej = true;
               end
           end
           if ~alreadyRej
              numRejected = numRejected+1;
              idsRejected(length(idsRejected)+1) = stepTable.id(iTrace); % Add this ID# to those already rejected.
              % Build table to add to outRej.
              rejTable = stepTable(iTrace,:);
              % Grab numSteps, we're going to replace it with a cell.
              numSteps = stepTable.numSteps(iTrace);
              % Get rid of variables numSteps, stepSizes, and stepInfo.
              rejTable(:,{'numSteps','stepSizes','stepInfo'}) = [];
              % Re-add numSteps as a cell.
              rejTable.numSteps = {numSteps};
              % Add the variable reasonRej.
              rejTable.reasonRej = {'msa'};
              % Add rejTable to outRej.
              outRej = [outRej;rejTable];
           end
           break; 
        end
    end
end


%% Build outAcc.
%       outAcc.id
%       outAcc.numSteps
%       outAcc.finalSNR
%       outAcc.chiSquare
%       outAcc.chiSquareRatio
%       outAcc.avgStepSize
%       outAcc.stdStepSize
%       outAcc.idealTrace
for iTrace = 1:numTraces
    % If this ID doesn't appear in idsRejected, accept the trace.
    if ~any(idsRejected==stepTable.id(iTrace))
        % Build table to add to outAcc.
        accTable = stepTable(iTrace,:);
        % Grab numSteps, we're going to replace it with a cell.
        numSteps = stepTable.numSteps(iTrace);
        % Get rid of variables numSteps, stepSizes, and stepInfo.
        accTable(:,{'numSteps','stepSizes','stepInfo'}) = [];
        % Re-add numSteps as a cell.
        accTable.numSteps = {numSteps};
        % Add accTable to outAcc.
        outAcc = [outAcc;accTable];
    end
end


%% Best traces

% Find the best trace, one for each # of steps.
% Order: SNR, chi square ratio, chi squared.

% Find all #'s of steps.
NumLevels = [];
for iTrace = 1:numTraces
    numSteps = stepTable.numSteps(iTrace);
    NumLevels(numel(NumLevels)+1) = numSteps;
end
stepsUQ = unique(NumLevels);

% Make a vector of all final SNR values, in order.
outSNRs = [];
for iTrace = 1:numTraces
   finalSNR = stepTable.finalSNR(iTrace);
   outSNRs(numel(outSNRs)+1) = finalSNR;
end

% bestTraceID is 2-col array: 
% 1st col = # steps,
% 2nd col = ID of best trace.
for i=1:length(stepsUQ)
   bestTraceID(i,1) = stepsUQ(i); % # steps.
   % Find indices of all traces with this # of steps.
   indsHere = find(NumLevels==stepsUQ(i));
   % Find SNRs of all traces with this # of steps.
   snrsHere = outSNRs(indsHere);
   % Find the max SNR for this # of steps (best SNR = best trace).
   maxSNR = max(snrsHere);
   snrInd = find(outSNRs==maxSNR);
   % if length(snrInd) is 1, then there is only 1 trace with that SNR and
   % that is the best trace.
   if length(snrInd)==1
    % Trace ID = index in traces of maximum SNR.
    bestTraceID(i,2) = snrInd;
   else
    maxchi2 = max(chi2ratioVec(snrInd));
    % Assume looking for MAXIMUM chi squared ratio.
    chi2Ind = find(chi2ratioVec==maxchi2);
    % If length(chi2Ind) is 1, then there is only 1 trace with that chi 2
    % ratio and that is the best trace.
    if length(chi2Ind)==1
        bestTraceID(i,2) = chi2Ind;
    else
        maxchival = max(chi2Vec(chi2Ind));
        % Assume looking for MINIMUM chi square value.
        chiValInd = find(chi2Vec==maxchival);
        bestTraceID(i,2) = chiValInd;
    end
   end
end



%% Find indeterminate traces

% Find indeterminate step numbers.
numAcc = height(outAcc);
if numAcc==0
   return; 
end

% Calculate avg step size for all passing traces.
avgS = [];
for iA = 1:numAcc
   %thisInd = outAcc.id(iA); % Id # for this trace. 
   avgStepSize = outAcc.avgStepSize(iA);
   avgS(length(avgS)+1) = avgStepSize;
end
overallAvg = mean(avgS);

% Loop over outRej to see if any initial intensity is too large,
% i.e. more than params.indeter*average step size.
% Make a new table loopOverMe to avoid difficulties deleting rows from
% outRej.
loopOverMe = outRej;
for iD = 1:height(loopOverMe)
    traceID = loopOverMe.id(iD);
    idealTrace = loopOverMe.idealTrace(iD,:);
    startVal = mean(idealTrace(2:11));
    finalVal = mean(idealTrace(end-10:end));
    signal = abs(startVal-finalVal);
    % If start is more than the threshold- NM2, less- NM1.
    % If signal>threshold, call it NM2.
    if signal>(params.indeter*overallAvg)
        % NM2
        % Find the row in outRej that matches the ID from loopOverMe.
        rowID = find(outRej.id==traceID);
        % Extract this row, changed numSteps to {'NM2'}.
        thisRow = outRej(rowID,:);
        thisRow.numSteps = {'NM2'};
        % Delete the 'reasonRej' field.
        thisRow(:,'reasonRej') = [];
        % Delete this row from outRej and add it to outAcc.
        outRej(rowID,:) = [];
        outAcc = [outAcc;thisRow];
    elseif (signal<(params.indeter*overallAvg) && signal>(2*overallAvg))
        % If signal is between the threshold and 2x the average, call
        % it NM1.
        % Find the row in outRej that matches the ID from loopOverMe.
        rowID = find(outRej.id==traceID);
        % Extract this row, changed numSteps to {'NM1'}.
        thisRow = outRej(rowID,:);
        thisRow.numSteps = {'NM1'};
        % Delete the 'reasonRej' field.
        thisRow(:,'reasonRej') = [];
        % Delete this row from outRej and add it to outAcc.
        outRej(rowID,:) = [];
        outAcc = [outAcc;thisRow];
    end
end


