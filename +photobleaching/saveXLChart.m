function saveXLChart(filename,ysheetrange,chartname,seriesname,xcaption,ycaption, varargin )
%SAVEXLCHART Will save a chart with specified parameters to pre-existing excel file filename.
%   varargin can contain xsheetrange,charttype.
% Syntax:
% SAVEXLCHART(filename,ysheetrange,chartname,seriesname,xcaption,ycaption)
% SAVEXLCHART(filename,ysheetrange,chartname,seriesname,xcaption,ycaption,xvalues)
% SAVEXLCHART(filename,ysheetrange,chartname,seriesname,xcaption,ycaption,xvalues,charttype)
%
% Description:
% Will save a chart to a pre-existing excel workbook with a specified y
% sheet range, name, series name and captions. The user also has the option
% to specify x sheet range (as a string, similar to y sheet range) and
% chart type (another string argument).
%
% Input:
% filename (string) - pre-existing excel file name.
% ysheetrange (string) - string in excel syntax specifying the sheet range
% for the y-values of the chart.
% chartname (string) - name for the chart.
% seriesname (string) - name for the series on the chart.
% xcaption (string) - caption for the x-axis.
% ycaption (string) - caption for the y-axis.
% xvalues (optional) (string) - string in excel syntax specifying the
% sheet range for the x-values of the chart.
% charttype (optional) (string) - type of chart recognized by excel.

% Open up the active server and get a workbook.
try
        Excel = actxserver('Excel.Application');
catch
        Excel = [];	
end

% Make the workbook invisible.
set(Excel,'Visible',0); 

% Open pre-existing file filename.
Workbook = Excel.workbooks.Open(filename);

% Add a chart to the workbook.
Chart = invoke(Workbook.Charts,'Add');
Chart.Name = chartname;

% Delete the unnecessary parts of the chart.
ExpChart = Excel.ActiveSheet;
ExpChart.Activate;
try
    for i=1:100 % What number here?
        Series = invoke(Excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
    end
catch e
end 

%Insert a Chart for desired columns.
NewSeries = invoke(Excel.ActiveChart.SeriesCollection,'NewSeries');
if (~isempty(varargin)) && (~isempty(varargin{1,1}))
    NewSeries.XValues = varargin{1,1};
end
NewSeries.Values  = ysheetrange;
NewSeries.Name    = seriesname; %'=Sheet3!A15';

% Set chart type.
if (length(varargin)>1)
    if ~isempty(varargin{1,2})
    Excel.ActiveChart.ChartType = varargin{1,1};
    end
end

% Set the axes
% Set the x-axis
Axes = invoke(Excel.ActiveChart,'Axes',1);
set(Axes,'HasTitle',1);
set(Axes.AxisTitle,'Caption',xcaption)
% % Set the y-axis
Axes = invoke(Excel.ActiveChart,'Axes',2);
set(Axes,'HasTitle',1);
set(Axes.AxisTitle,'Caption',ycaption)

% Give the Chart a title
Excel.ActiveChart.HasTitle = 1;
Excel.ActiveChart.ChartTitle.Characters.Text = chartname; 

% Save and close the workbook.
invoke(Excel.ActiveWorkbook,'Save'); 
Workbook.Close();

end

