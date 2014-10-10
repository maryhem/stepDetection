% function [ out_sig, numL, levels, out_snr ] = stepDetection(rawTraceData, snr, phi, sigStep, minStep)
function [ stepTable ] = stepDetection(rawTraceData, snr, phi, sigStep, minStep)
% STEPDETECTION The "reevaluation" step of the step detection algorithm.
%
% Syntax:
% stepTable = stepDetection(rawTraceData, snr, phi, sigStep, minStep)
% 
% Description:
% Calls annealing and scanning phases during execution.
%
% Input:
% rawTraceData (MxN) - The raw trace data where each row is a single trace.
% snr (scalar) - initial signal to noise ratio.
% phi - initial step threshold.
% sigStep - how many thresholds to consider.
% minStep - minimum number of frames that constitutes a level.
%
% Output:
% stepTable (table) - Table with the step detection results for each trace.
%      Variables:
%      * numSteps (scalar) - Number of detected steps.
%      * avgStepSize (scalar) - Average value of the 'drop' between steps.
%      * stdStepSize (scalar) - Standard deviation of the 'drops' between
%      steps.
%      * stepSizes (1xN) - Vector of the sizes of all the 'drops' between
%      steps.
%      * idealTrace (1xN) - Idealized trace.
%      * stepInfo (3xN) - 1 col/detected step. row 1 = step level, row 2 =
%      start index, row 3 = end index.
%      * finalSNR (scalar) - Final calculated signal to noise ratio.

narginchk(5, 5);

% Create empty table.
stepTable = table;

% Determine the number of traces.
numTraces = size(rawTraceData,1);

% Run the step detection algorithm for each trace.
for iTrace = 1:numTraces
   
    % Initially set 'previous' number of levels to infinity.
    prevLevels = Inf;
    
    % Set initial sigma to 0.
    sigma = 0;
    
    % This will be the 'stepInfo' for this trace.
    levels = [];
    
    % Get this trace from rawTraceData.
    thisTrace = rawTraceData(iTrace,:);
    
    % Continue calling annealing phase until calculate number of steps
    % reaches a constant.
    keepLooping = true;
    while keepLooping
       
        % Calculate initial NFF (noise estimate) and SNR.
        [nffVal,snr] = photobleaching.NFF(thisTrace,sigma,levels,snr);
        
        % Run annealing phase. Updates trace, sigma.
        [thisTrace,numL,sigma,levels] = photobleaching.annealingPhase(thisTrace, sigStep, nffVal, snr, phi);
        
        % Quit when number of levels reaches a constant.
        if numL==prevLevels
            break;
        end
        prevLevels = numL;
        
    end
    
    % After step detection is finished, delete any detected steps with
    % a duration of fewer frames than minStep.
    tempLevels = levels;
    % Reinitialize levels and just add on any steps of acceptable length.
    levels = [];
    numL = 0;
    for i=1:size(tempLevels,2)
       levelWidth = tempLevels(3,i)-tempLevels(2,i);
       % If step duration is long enough, add step to levels.
       if levelWidth>=minStep
           numL = numL+1;
           levels(:,numL) = tempLevels(:,i);
       end
    end
    
    % Plot the idealized trace to the current axes.
    plot(thisTrace,'k');
    hold on;
    
    % Overplot each detected step on the idealized trace in a random color.
    xplt = [];
    yplt = [];
    ind = 1;
    for i=1:size(levels,2)
        % xvals = x values of this step, i.e. start index to end index.
        xvals = levels(2,i):levels(3,i);
        % yvals = y values of this step, i.e. the height of the step.
        yvals = zeros([1,numel(xvals)]);
        yvals(:) = levels(1,i);
        % Plot this step in a random color.
        plot(xvals,yvals,'Color',rand([1,3]));
        hold on;
    end
    % Pause briefly for the plot to render on screen.
    pause(0.01);
    
    % Calculate NFF one last time to get finalSNR.
    [nffVal,finalSNR] = photobleaching.NFF(thisTrace,sigma,levels,snr);
    
    % Load data from this trace into struct 'traceStruct', and then convert
    % to a table and concatenate to stepTable.
    traceStruct.numSteps = numL;
    stepS = photobleaching.stepSizes(levels,numL,thisTrace);
    if numL>0
        traceStruct.avgStepSize = mean(stepS);
        traceStruct.stdStepSize = std(stepS);
    else
        traceStruct.avgStepSize = 0;
        traceStruct.stdStepSize = 0;
    end
    traceStruct.stepSizes = {stepS};
    traceStruct.idealTrace = thisTrace;
    traceStruct.stepInfo = levels;
    traceStruct.finalSNR = finalSNR;

    % Convert struct to table and append to stepTable.
    stepTable = [stepTable;struct2table(traceStruct,'AsArray',true)];
    
end

end

