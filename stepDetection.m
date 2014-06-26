function [ out_sig, numL, levels, out_snr ] = stepDetection( I, guiParams )
%STEPDETECTION The "reevaluation" step of the step detection algorithm.
%   Calls annealing and scanning phases during execution.

prevLevels = Inf;

%params = loadConfig();
params = guiParams;
snrVal = params.snr;
phiVal = params.phi;
sigmaVal = 0;
levels = [];

keepLooping = true;
while keepLooping
   
    [nffVal,snrVal] = NFF(I,sigmaVal,levels,params);
    
    % Update values for # of levels, sigma.
    [I,numL,sigmaVal,levels] = annealingPhase(I, params, nffVal, snrVal, phiVal);
    
    % Quit when number of levels reaches a constant.
    if numL==prevLevels
        break;
    end
    prevLevels = numL;
    
end

% Get rid of levels smaller than params.minstep.
tempLevels = levels;
levels = [];
numL = 0;
for i=1:size(tempLevels,2)
   levelWidth = tempLevels(3,i)-tempLevels(2,i);
   if levelWidth>=params.minstep
       numL = numL+1;
       levels(:,numL) = tempLevels(:,i);
   end
end

out_sig = I;
plot(I,'k');
hold on;

xplt = [];
yplt = [];
ind = 1;
for i=1:size(levels,2)
    xvals = levels(2,i):levels(3,i);
    yvals = zeros([1,numel(xvals)]);
    yvals(:) = levels(1,i);
    plot(xvals,yvals,'Color',rand([1,3]));
    hold on;
end
pause(0.01);

% Calculate nff to get out_snr.
[nffVal,out_snr] = NFF(I,sigmaVal,levels,params);

end

