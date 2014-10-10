function [ out_signal, out_numLevels, levels ] = scanningPhase( I, threshold )
%SCANNINGPHASE Scanning phase of the step detection algorithm.
%   Requires intensity signal vector I and threshold change. Returns
%   updated signal and number of levels detected.

% Keep track of the "height" of each level, and where they start and end. Used for debugging later.
levels = [];
startLevelX = 1;

out_signal = [];
numLevels = 0;
prevLoop = -1;
framesSince = 0;

% First point is initial reference.
refInd = 1;
ref = I(refInd);

keepLooping = true;
while keepLooping
    
    for i=2:numel(I)-1

        %if I(i)>ref
        if (I(i)>ref && abs(ref-I(i))>threshold)
    %       if framesSince>params.minstep
               numLevels = numLevels+1;
               I(refInd:i) = mean(I(refInd:i));
               %if ~isnan(mean(I(refInd:i)))
               %numLevels = numLevels+1;
               levels(1,numLevels) = mean(I(refInd:i));
               levels(2,numLevels) = startLevelX;
               levels(3,numLevels) = i; % Index of the end of this level.
               %end
               refInd = i+1;
               ref = I(refInd);
               startLevelX = refInd;
               framesSince = 0;
     %      end
        elseif (I(i)>ref && abs(ref-I(i))<threshold)
           % Number of levels does not increase.
           I(refInd:i) = mean(I(refInd:i));
           refInd = i+1;
           ref = I(refInd);
           framesSince = framesSince + 1;
        elseif (I(i)<ref && abs(ref-I(i))<threshold)
            % Number of levels does *not* increase in this case.
           I(refInd:i) = mean(I(refInd:i));
           refInd = i+1;
           ref = I(refInd);
           framesSince = framesSince + 1; % Another frame for this level.
        elseif (I(i)<ref && abs(ref-I(i))>threshold)
  %         if framesSince>params.minstep
               numLevels = numLevels+1;
               levels(1,numLevels) = I(refInd);
               levels(2,numLevels) = startLevelX;
               levels(3,numLevels) = i-1;
               refInd = i;
               ref = I(refInd);
               startLevelX = refInd;
               framesSince = 0;
    %       end
        end
    end
    
    if (numLevels==prevLoop)
       break; 
    end
    prevLoop = numLevels;
    numLevels = 0;
    framesSince = 0;
    startLevelX = 1;
    levels = [];
    
end

for i=1:size(levels,2)
   try
   if isnan(levels(1,i))
      levels(:,i) = [];
      numLevels = numLevels-1;
   end
   catch e
      break; 
   end
end
%levels = levels(~isnan(levels));

out_numLevels = numLevels;
out_signal = I;

end

