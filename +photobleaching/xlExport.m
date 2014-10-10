function xlExport( appData, numBinsStep, numBinsSNR )
%XLEXPORT Function to export experimental output to excel and plot charts.
%   
% Syntax:
% xlExport(appData,numBinsStep,numBinsSNR)
% 
% Description:
% Builds and exports 3 sheets (1st = accepted traces, 2nd = rejected
% traces, 3rd = general experimental info) and charts of experimental data.
%
% Input:
% appData - Structure containing most experimental data. Includes:
%   appData.RawData (MxN) - raw trace data.
%   appData.GafneyFile - string containing filename of Gafney excel file.
%   appData.numRows - Total # of traces.
%   appData.outAcc - table of accepted traces.
%   appData.outRej - table of rejected traces.
%   appData.bestTraceID - Nx2 array of best trace IDs. 1st row = # of
%   steps, 2nd row = id of best trace for that # of steps.
%   appData.possIndeter - table of traces with 0 detected steps.
% numBinsStep (scalar) - # of bins for the step size histogram. 
% numBinsSNR (scalar) - # of bins for the SNR histogram.

timeNow = clock;
fileName = datestr(timeNow);
fileName = [fileName,'.xlsx'];
fileName = strrep(fileName, ' ', '_');
fileName = strrep(fileName, ':', '_');
% Write accepted traces to sheet 1, rejected traces to sheet 2.
sheet1 = cell(0);
sheet2 = cell(0);

% Initialize column titles in sheet1 and sheet2.
sheet1(1,2) = {'Index Number'};
sheet2(1,2) = {'Index Number'};
sheet1(1,3) = {'Number of Steps'};
sheet2(1,3) = {'Reason for rejection'};
sheet2(1,4) = {'Number of Steps'};
sheet1(1,4) = {'Signal to Noise Ratio'};
sheet2(1,5) = {'Signal to Noise Ratio'};
sheet1(1,5) = {'Chi Squared Value'};
sheet2(1,6) = {'Chi Squared Value'};
sheet1(1,6) = {'Chi Squared Ratio'};
sheet2(1,7) = {'Chi Squared Ratio'};
sheet1(1,7) = {'Average Step Size'};
sheet2(1,8) = {'Average Step Size'};
sheet1(1,8) = {'Stardard Deviation of Step Size'};
sheet2(1,9) = {'Stardard Deviation of Step Size'};
sheet1(1,9) = {'X-Y Coordinates (From Gafney Program?)'};
sheet2(1,10) = {'X-Y Coordinates (From Gafney Program?)'};


%% Start sheet 1 with current row for sheet1 (accepted traces).
curr1Row = 2;

for iArow = 1:height(appData.outAcc)
    sheet1(curr1Row,1) = {'Background Subtracted Data From Gafney Program -->  '};
    sheet1(curr1Row+1,1) = {'Final Idealized Trace Data -->'}; 
    sheet1(curr1Row,2) = {appData.outAcc.id(iArow)-1}; % Trace ID (starting from 1, not 0).
    sheet1(curr1Row,3) = appData.outAcc.numSteps(iArow); % Should already be a cell.
    sheet1(curr1Row,4) = {appData.outAcc.finalSNR(iArow)};
    sheet1(curr1Row,5) = {appData.outAcc.chiSquare(iArow)};
    sheet1(curr1Row,6) = {appData.outAcc.chiSquareRatio(iArow)};
    sheet1(curr1Row,7) = {appData.outAcc.avgStepSize(iArow)};
    sheet1(curr1Row,8) = {appData.outAcc.stdStepSize(iArow)};
    % Add trace and raw data to output.
    idealTrace = appData.outAcc.idealTrace(iArow,:);
    traceID = appData.outAcc.id(iArow);
    rawData = appData.RawData(traceID,appData.startframe:end);
    if length(idealTrace)~=length(rawData)
       error('Mismatched trace lengths.') 
    end
    for iAcol = 1:length(idealTrace);
       sheet1(curr1Row,iAcol+9) = {rawData(iAcol)};
       sheet1(curr1Row+1,iAcol+9) = {idealTrace(iAcol)}; % Idealized trace data.
    end
    curr1Row = curr1Row+2;
end

% Add best trace (for each # steps) and trace ID to the bottom of accepted
% traces.
curr1Row = curr1Row+1;
sheet1(curr1Row,1) = {'Num Steps'};
sheet1(curr1Row,2) = {'Best Trace ID'};
for iT = 1:size(appData.bestTraceID,1)
    curr1Row = curr1Row+1;
    sheet1(curr1Row,1) = {appData.bestTraceID(iT,1)};
    sheet1(curr1Row,2) = {appData.bestTraceID(iT,2)-1};
end


%% Start sheet 2 (rejected traces).
curr2Row = 2;

for iRrow = 1:height(appData.outRej)
    sheet2(curr2Row,1) = {'Background Subtracted Data From Gafney Program -->  '};
    sheet2(curr2Row+1,1) = {'Final Idealized Trace Data -->'}; 
    sheet2(curr2Row,2) = {appData.outRej.id(iRrow)-1}; % Trace ID (starting from 1, not 0).
    sheet2(curr2Row,3) = appData.outRej.reasonRej(iRrow); % Should already be a cell.
    sheet2(curr2Row,4) = appData.outRej.numSteps(iRrow); % Should already be a cell.
    sheet2(curr2Row,5) = {appData.outRej.finalSNR(iRrow)};
    sheet2(curr2Row,6) = {appData.outRej.chiSquare(iRrow)};
    sheet2(curr2Row,7) = {appData.outRej.chiSquareRatio(iRrow)};
    sheet2(curr2Row,8) = {appData.outRej.avgStepSize(iRrow)};
    sheet2(curr2Row,9) = {appData.outRej.stdStepSize(iRrow)};
    % Add trace and raw data to output.
    idealTrace = appData.outRej.idealTrace(iRrow,:);
    traceID = appData.outRej.id(iRrow);
    rawData = appData.RawData(traceID,appData.startframe:end);
    if length(idealTrace)~=length(rawData)
       error('Mismatched trace lengths.') 
    end
    for iRcol = 1:length(idealTrace);
       sheet2(curr2Row,iRcol+10) = {rawData(iRcol)};
       sheet2(curr2Row+1,iRcol+10) = {idealTrace(iRcol)}; % Idealized trace data.
    end
    curr2Row = curr2Row+2;
end

% Add ND0 indeterminate traces.
for ind0row = 1:height(appData.possIndeter)
    sheet2(curr2Row,1) = {'Background Subtracted Data From Gafney Program -->  '};
    sheet2(curr2Row+1,1) = {'Final Idealized Trace Data -->'};
    sheet2(curr2Row,2) = {appData.possIndeter.id(ind0row)};
    sheet2(curr2Row,4) = {'0'};%{appData.params.NumLevels(thisIndex)};
    % Add trace and raw data to output.
    idealTrace = appData.possIndeter.idealTrace(ind0row,:);
    traceID = appData.possIndeter.id(ind0row);
    rawData = appData.RawData(traceID,appData.startframe:end);
    if length(idealTrace)~=length(rawData)
       error('Mismatched trace lengths.') 
    end
    for iAcol = 1:length(idealTrace)
       sheet2(curr2Row,iAcol+10) = {rawData(iAcol)};
       sheet2(curr2Row+1,iAcol+10) = {idealTrace(iAcol)};
    end
    curr2Row = curr2Row+2;
end


%% Sheet 3, with whatever metadata.
sheet3 = cell(0);

% Analysis params
sheet3 = cell(0);
sheet3(1,1) = {'User defined parameters: Analysis'};
sheet3(2,1) = {'PSDIS'};
sheet3(2,2) = {appData.snr};
sheet3(3,1) = {'TIN'};
sheet3(3,2) = {appData.sigStep};
sheet3(4,1) = {'Minimum step length'};
sheet3(4,2) = {appData.minStep};
sheet3(5,1) = {'Starting frame'};
sheet3(5,2) = {appData.startframe};
sheet3(6,1) = {'Acquisition rate'};
sheet3(6,2) = {appData.frameRate};
% Trace rejection params
sheet3(1,3) = {'User defined parameters: Trace rejection'};
sheet3(2,3) = {'Confidence'};
sheet3(2,4) = {appData.params.alpha};
sheet3(3,3) = {'Min SNR'};
sheet3(3,4) = {appData.params.minsnr};
sheet3(4,3) = {'Step Size Deviation'};
sheet3(4,4) = {appData.params.maxstepsize};
sheet3(5,3) = {'Max Initial Intensity'};
sheet3(5,4) = {appData.params.indeter};

% Add a list of experimental parameters for users to enter in themselves.
% Put these in columns 8 and 9. 
sheet3(1,8) = {'Experimental Parameters: Fill In'};
sheet3(2,8) = {'Gafney Excel Export File Name:'};
sheet3(2,9) = {appData.GafneyFile};
sheet3(3,8) = {'Cell type used:'};
sheet3(4,8) = {'Time point:'};
sheet3(5,8) = {'Replicate number:'};
sheet3(6,8) = {'Flurophore used:'};
sheet3(7,8) = {'Name of fluorescent particle:'};
sheet3(8,8) = {'Microscope used:'};
sheet3(9,8) = {'Number of cameras in analysis: (1 or 2)'};
sheet3(10,8) = {'Camera 1 GAIN value:'};
sheet3(11,8) = {'Camera 2 GAIN value (if used):'};
% Table of laser parameters.
sheet3(12,8) = {'Laser 1 used:'}; 
sheet3(12,10) = {'Laser 1 AOTF value:'};
sheet3(12,12) = {'Laser 1 Filter Set Name:'};
sheet3(13,8) = {'Laser 2 used:'};
sheet3(13,10) = {'Laser 2 AOTF value:'};
sheet3(13,12) = {'Laser 2 Filter Set Name:'};
sheet3(14,8) = {'Laser 3 used:'};
sheet3(14,10) = {'Laser 3 AOTF value:'};
sheet3(14,12) = {'Laser 3 Filter Set Name:'};

currRow = 6;

% Do these stats for accepted traces only.
numAcc = height(appData.outAcc);

% Step number distribution.
currRow = currRow+2;
sheet3(currRow,1) = {'Step number distribution'};
distrStart = num2str(currRow+1);
freq = []; % 1st col = # steps, 2nd = frequency.
numFreqs = 0;
for iTrace = 1:height(appData.outAcc)
    numSteps = appData.outAcc.numSteps(iTrace);
    numSteps = numSteps{1};
    % If numSteps is not numeric than it's 'NM1' or 'NM2' and we'll skip
    % it.
    if ~isnumeric(numSteps)
        continue;
    end
    % Loop over rows in freq. If the number of steps matches the first col
    % in a row, add one to the count in the second col.
    found = false;
    for iFreq = 1:size(freq,1)
       if numSteps==freq(iFreq,1)
          found = true;
          % Add one to the count for this # of steps.
          freq(iFreq,2) = freq(iFreq,2)+1;
          break;
       end
    end
    % If no matching row was found in freq, create a new row and update its
    % count to 1.
    if ~found
       tempthing = zeros([1,2]);
       tempthing(1,1) = numSteps;
       tempthing(1,2) = 1;
       freq = vertcat(freq,tempthing);
    end
end
distrEnd = num2str(currRow+size(freq,1)); % For the chart.
% Sort by # of steps.
if ~isempty(freq)
    freq = sortrows(freq,1);
end

for iFreq = 1:size(freq,1)
   sheet3(currRow+iFreq,1) = {freq(iFreq,1)};
   sheet3(currRow+iFreq,2) = {freq(iFreq,2)};
end

currRow = currRow + size(freq,1);

% Step size distribution.
currRow = currRow+2;
sheet3(currRow,1) = {'Step size distribution'};
ssDistStart = num2str(currRow+1);
if numAcc>0
   % stepSizeDistr will calculate average step size for each # of steps.
   stepSizeMat = photobleaching.stepSizeDistr(numBinsStep,appData.outAcc);
   for iBin = 1:numBinsStep-1
       sheet3(currRow+iBin,1) = {stepSizeMat(iBin,1)}; 
       sheet3(currRow+iBin,2) = {stepSizeMat(iBin,2)};
   end
   sheet3(currRow+numBinsStep,1) = {strcat(num2str(numBinsStep),'+')};
   sheet3(currRow+numBinsStep,2) = {stepSizeMat(numBinsStep,2)};
   ssDistEnd = num2str(currRow+size(stepSizeMat,1));
   currRow = currRow + numBinsStep;
end

% SNR distribution.
currRow = currRow+2;
sheet3(currRow,1) = {'SNR distribution'};
snrDistStart = num2str(currRow+1);
if numAcc>0
    % Build accSNRs for traces with numeric numSteps.
    accSNRs = [];
    for iTrace = 1:height(appData.outAcc)
        numSteps = appData.outAcc.numSteps(iTrace);
        numSteps = numSteps{1};
        % If numSteps is not numeric than it's 'NM1' or 'NM2' and we'll skip
        % it.
        if ~isnumeric(numSteps)
            continue;
        end
        accSNRs(length(accSNRs)+1) = appData.outAcc.finalSNR(iTrace);
    end
    minVal = min(accSNRs);
    maxVal = max(accSNRs);
    % Create numBinsSNR equally sized bins.
    binSize = (maxVal-minVal)/numBinsSNR;
    % snrArr: 1st row = beginning of bin, 2nd row = end of bin, 3rd row =
    % frequency.
    snrArr = zeros([numBinsSNR,3]);
    for iBin = 1:numBinsSNR
       snrArr(iBin,1) = (iBin-1)*binSize+minVal;
       snrArr(iBin,2) = iBin*binSize+minVal;
    end
    % Loop over all accepted SNRs.
    for isnr = 1:length(accSNRs)
        thisVal = accSNRs(isnr);
        foundBin = false;
        % Try to find a bin for this SNR.
        for iBin = 1:numBinsSNR
            % Look for value between ranges, or equal to the lower bound.
            if (thisVal>snrArr(iBin,1) && thisVal<snrArr(iBin,2)) || (thisVal==snrArr(iBin,1))
                % Add one to this frequency count.
                snrArr(iBin,3) = snrArr(iBin,3)+1;
                foundBin = true;
                break;
            end
        end
        % If a bin was not found, it is an upper edge value (for the last bin). Find the edge and
        % add it to the bin before the edge.
        if ~foundBin
           for iBin=1:numBinsSNR
              if (thisVal==snrArr(iBin,2))
                  snrArr(iBin,3) = snrArr(iBin,3)+1;
                  foundBin = true;
                  break;
              end
           end
        end
    end
    for iBin = 1:numBinsSNR
       sheet3(currRow+iBin,1) = {str2double(sprintf('%.3f',snrArr(iBin,1)))};%{snrArr(iBin,1)}; 
       sheet3(currRow+iBin,2) = {str2double(sprintf('%.3f',snrArr(iBin,2)))}; %{snrArr(iBin,2)};
       sheet3(currRow+iBin,3) = {snrArr(iBin,3)};
    end
    snrDistEnd = num2str(currRow+size(snrArr,1));
end

% Write excel files to specified worksheets.
xlswrite(fileName,sheet1,1); 
xlswrite(fileName,sheet2,2);
xlswrite(fileName,sheet3,3);


%% Get full file of export.
path = which('StepDetect.m');
pathname = fileparts(path);
fileName = fullfile(pathname,fileName);

% Save XL charts.
xsheetrange = strcat('Sheet3!$A$',distrStart,':$A$',distrEnd); % x-vals col
ysheetrange = strcat('Sheet3!$B$',distrStart,':$B$',distrEnd); % y-vals col
photobleaching.saveXLChart(fileName,ysheetrange,'Step Number Distribution','Step # Distribution','# of photobleaching events per particle','Number of Particles',xsheetrange,''); %,'xlLine'); %,'xlBarClustered');
if numAcc>0
    xsheetrange = strcat('Sheet3!$A$',ssDistStart,':$A$',ssDistEnd); % x-vals col
    ysheetrange = strcat('Sheet3!$B$',ssDistStart,':$B$',ssDistEnd); % y-vals col (note: C column for yvals.)
    photobleaching.saveXLChart(fileName,ysheetrange,'Step Size Distribution','Step sizes','Number of Steps per Trace','Avg Step Size',xsheetrange); 
    xsheetrange = strcat('Sheet3!$A$',snrDistStart,':$A$',snrDistEnd); % x-vals col
    ysheetrange = strcat('Sheet3!$C$',snrDistStart,':$C$',snrDistEnd); % y-vals col (note: C column for yvals.)
    photobleaching.saveXLChart(fileName,ysheetrange,'SNR Distribution','SNR sizes','SNR','Frequency',xsheetrange);
end

% Change sheet names.
e = actxserver('Excel.Application'); % # open Activex server
ewb = e.Workbooks.Open(fileName); % # open file (enter full path!)
ewb.Worksheets.Item(1).Name = 'Accepted Traces'; % # rename 1st sheet
ewb.Worksheets.Item(2).Name = 'Rejected Traces';
ewb.Worksheets.Item(3).Name = 'Info';
ewb.Save % # save to the same file
ewb.Close(false)
e.Quit

end

