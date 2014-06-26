function [ nff, snr ] = NFF( I,sigma,levels,params )
%NFF Calculates standard deviation of flourescence fluctuations.
%   Requires intensity signal data I, provides an estimate of noise.
%   Sigma is the threshold to not exceed, should one exist, and 0 otherwise.

T = numel(I);
numPoints = T; % Will be decreased if we're excluding steps above sigma.

if ~isempty(levels)
    % Find min and max difference between levels.
    minLevels = 0;
    maxLevels = Inf;
    if size(levels,2)<2
       delLevel = abs(levels(1,1)-min(I)); 
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
           meanVec(length(meanVec)+1) = abs(levels(1,1)-min(I)); 
        end
        for i=2:size(levels,2)
            meanVec(length(meanVec)+1) = levels(1,i)-levels(1,i-1);
        end
        sigma = abs(mean(meanVec));
    end
end

% Calculate std of delIs.
delIVec = [];
for i=1:(T-1)
   delI = abs(I(i+1)-I(i)); 
   if (delI<sigma || sigma==0)
    delIVec(length(delIVec)+1) = delI;
   end
end

delIVec=delIVec(~isnan(delIVec));
nff = std(delIVec);
if sigma==0
    snr = params.snr;
else
    snr = sigma/nff;
end





% Ibar = (I(T)-I(1))/(T-1); % Does this number stay the same as we decrease numPoints?
% 
% s = 0.0; % Sum
% for i=1:(T-1)
%    delI = I(i+1)-I(i); 
%    % Do not add to sum if delI exceeds sigma.
%    if (sigma>0)&&(delI>sigma)
%        numPoints = numPoints-1;
%    else
%        s = s + ((delI - Ibar)^2); 
%    end
% end
% 
% nff = sqrt((1/(numPoints-1))*s);

end

