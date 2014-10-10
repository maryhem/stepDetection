function varargout = StepDetect(varargin)
% STEPDETECT MATLAB code for StepDetect.fig
%      STEPDETECT, by itself, creates a new STEPDETECT or raises the existing
%      singleton*.
%
%      H = STEPDETECT returns the handle to a new STEPDETECT or the handle to
%      the existing singleton*.
%
%      STEPDETECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STEPDETECT.M with the given input arguments.
%
%      STEPDETECT('Property','Value',...) creates a new STEPDETECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StepDetect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StepDetect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StepDetect

% Last Modified by GUIDE v2.5 13-Aug-2014 13:40:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StepDetect_OpeningFcn, ...
                   'gui_OutputFcn',  @StepDetect_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before StepDetect is made visible.
function StepDetect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StepDetect (see VARARGIN)

% Clear screen.
clc;
fprintf('StepDetect Launched. \n');

% Choose default command line output for StepDetect
handles.output = hObject;

% Set axes
axes(handles.axes_data);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StepDetect wait for user response (see UIRESUME)
% uiwait(handles.mainWindow);


% --- Outputs from this function are returned to the command line.
function varargout = StepDetect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function tb_path_Callback(hObject, eventdata, handles)
% hObject    handle to tb_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_path as text
%        str2double(get(hObject,'String')) returns contents of tb_path as a double


% --- Executes during object creation, after setting all properties.
function tb_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_browse.
function pb_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pb_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile({'*.xlsx';'*.xls'},'Select files');
set(handles.tb_path,'String',[PathName,FileName]);

% Reset axes.
cla(handles.axes_data,'reset');

appData.GafneyFile = [PathName,FileName];
appData.RawData = xlsread([PathName,FileName]);
appData.RawData = appData.RawData'; % Transpose here.
appData.numRows = size(appData.RawData,1);
plot(appData.RawData(1,:),'k');

% Set any negative values in the raw data equal to 0.
for i=1:size(appData.RawData,1)
   negInds = find(appData.RawData(i,:)<0);
   appData.RawData(i,negInds)=0;
end

newString = ['Number of levels: ',num2str(0)];
set(handles.tb_levels,'String',newString);

% Update appData.
setappdata(handles.mainWindow, 'appData', appData);

% Update handles structure.
guidata(hObject, handles);



% Data plotting axes
function axes_data_CreateFcn(hObject, eventdata, handles)
% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in pb_analyze.
function pb_analyze_Callback(hObject, eventdata, handles)
% hObject    handle to pb_analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get appData.
appData = getappdata(handles.mainWindow, 'appData');

cla(handles.axes_data,'reset');
plot(appData.RawData(1,:),'k');

% Initialize main figure window strings.
newString = ['Number of levels: ',num2str(0)];
set(handles.tb_levels,'String',newString);
traceString = ['Traces Rejected: ',num2str(0),'/',num2str(0)];
set(handles.text4,'String',traceString);
anaString = ['Analyzing: ',num2str(0),'/',num2str(appData.numRows)];
set(handles.text14,'String',anaString);

% Create empty stepTable.
appData.stepTable = table;

% Get params.
appData.phi = 1;
appData.snr = str2double(get(handles.tb_snr,'String'));
appData.sigStep = str2double(get(handles.tb_phi,'String'));
appData.minStep = str2double(get(handles.tb_minstep,'String'));
appData.frameRate = str2double(get(handles.tb_framerate,'String'));
appData.startframe = str2double(get(handles.tb_startframe,'String'));
contents = cellstr(get(handles.pm_alpha,'String'));
teststr = contents{get(handles.pm_alpha,'Value')};
appData.params.alpha = str2double(teststr);
appData.params.minsnr = str2double(get(handles.tb_minsnr,'String'));
appData.params.maxstepsize = str2double(get(handles.tb_maxstepsize,'String'));
appData.params.indeter = str2double(get(handles.tb_indeter,'String'));

% Empty possIndeter table.
appData.possIndeter = table;

addToRejected = 0;
for i=1:appData.numRows
    anaString = ['Analyzing: ',num2str(i),'/',num2str(appData.numRows)];
    set(handles.text14,'String',anaString);
    thisRow = appData.RawData(i,appData.startframe:end);
    thisRow = thisRow(~isnan(thisRow));
    % Traces will be analyzed one at a time.
    newTable = photobleaching.stepDetection(thisRow,appData.snr,appData.phi,appData.sigStep,appData.minStep);
    newTable.id = i; % Add id field to the new table.
    numSteps = newTable.numSteps;
    if numSteps==0
        addToRejected = addToRejected+1;
        % Instead of adding data to 'params.possIndeter', assign to new table.
        % Get rid of variables numSteps, stepSizes, and stepInfo.
        newTable(:,{'numSteps','stepSizes','stepInfo'}) = [];
        % Re-add numSteps as a cell.
        newTable.numSteps = {0};
        % Add new row to appData.possIndeter.
        appData.possIndeter = [appData.possIndeter;newTable];
        % Update # of levels string.
        newString = ['Number of levels: ',num2str(0)];
        set(handles.tb_levels,'String',newString);
        % Update plot axes.
        if i~=appData.numRows
            cla(handles.axes_data,'reset');
            plot(appData.RawData(i+1,:),'k');
            pause(0.01);
        end
       continue; 
    end
    % Add newTable onto appData.stepTable.
    appData.stepTable= [appData.stepTable;newTable];
    % Update # of levels string.
    newString = ['Number of levels: ',num2str(newTable.numSteps)];
    set(handles.tb_levels,'String',newString);
    if i~=appData.numRows
        cla(handles.axes_data,'reset');
        plot(appData.RawData(i+1,:),'k');
        pause(0.01);
    end
end

fprintf('Analysis finished. Rejecting traces... \n');

% Call photobleaching.traceRejection, updated Traces Rejected string.
[appData.outAcc,appData.outRej,appData.bestTraceID] = photobleaching.traceRejection(appData.RawData(:,appData.startframe:end),appData.stepTable,appData.params);
numRejected = height(appData.outRej);
traceString = ['Traces Rejected: ',num2str(numRejected+addToRejected),'/',num2str(appData.numRows)];
set(handles.text4,'String',traceString);

fprintf('Trace rejection finished. \n');

% Update appData.
setappdata(handles.mainWindow, 'appData', appData);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pb_export.
function pb_export_Callback(hObject, eventdata, handles)
% hObject    handle to pb_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf('Export started. \n');

% Get appData.
appData = getappdata(handles.mainWindow, 'appData');

% Get # of bins.
numbinsstep = str2double(get(handles.tb_numbinsstep,'String'));
numbinssnr = str2double(get(handles.tb_numbinssnr,'String'));

% Do excel export + charts.
photobleaching.xlExport(appData,numbinsstep,numbinssnr);

fprintf('Export finished. \n');

% Update handles structure
guidata(hObject, handles);



function tb_snr_Callback(hObject, eventdata, handles)
% hObject    handle to tb_snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_snr as text
%        str2double(get(hObject,'String')) returns contents of tb_snr as a double


% --- Executes during object creation, after setting all properties.
function tb_snr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tb_phi_Callback(hObject, eventdata, handles)
% hObject    handle to tb_phi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_phi as text
%        str2double(get(hObject,'String')) returns contents of tb_phi as a double


% --- Executes during object creation, after setting all properties.
function tb_phi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_phi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tb_maxchi2_Callback(hObject, eventdata, handles)
% hObject    handle to tb_maxchi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_maxchi2 as text
%        str2double(get(hObject,'String')) returns contents of tb_maxchi2 as a double


% --- Executes during object creation, after setting all properties.
function tb_maxchi2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_maxchi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tb_framerate_Callback(hObject, eventdata, handles)
% hObject    handle to tb_framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_framerate as text
%        str2double(get(hObject,'String')) returns contents of tb_framerate as a double


% --- Executes during object creation, after setting all properties.
function tb_framerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tb_startframe_Callback(hObject, eventdata, handles)
% hObject    handle to tb_startframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_startframe as text
%        str2double(get(hObject,'String')) returns contents of tb_startframe as a double


% --- Executes during object creation, after setting all properties.
function tb_startframe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_startframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tb_minstep_Callback(hObject, eventdata, handles)
% hObject    handle to tb_minstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_minstep as text
%        str2double(get(hObject,'String')) returns contents of tb_minstep as a double


% --- Executes during object creation, after setting all properties.
function tb_minstep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_minstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_alpha.
function pm_alpha_Callback(hObject, eventdata, handles)
% hObject    handle to pm_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_alpha contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_alpha


% --- Executes during object creation, after setting all properties.
function pm_alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

string_list = {'0.95';'0.99'; '0.90'; '0.05'};

set(hObject,'String',string_list);

% Save
guidata(hObject, handles);



function tb_minsnr_Callback(hObject, eventdata, handles)
% hObject    handle to tb_minsnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_minsnr as text
%        str2double(get(hObject,'String')) returns contents of tb_minsnr as a double


% --- Executes during object creation, after setting all properties.
function tb_minsnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_minsnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tb_maxstepsize_Callback(hObject, eventdata, handles)
% hObject    handle to tb_maxstepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_maxstepsize as text
%        str2double(get(hObject,'String')) returns contents of tb_maxstepsize as a double


% --- Executes during object creation, after setting all properties.
function tb_maxstepsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_maxstepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

textbox_string = 'Description of Parameters: \n\n';
textbox_string = strcat(textbox_string, '\t Progressive Step Detection Initial SNR (PSDIS): This parameter is an estimated signal to noise ratio (SNR) that the program uses initially for iterative cleanup of the data.  Values should are intentionally left low and through rounds of smoothing will eventually reveal the "true" SNR.  The user is suggested to use values between 0.25 - 1.   \n \n');
textbox_string = strcat(textbox_string, '\t Threshold Iteration Number (TIN) is a parameter that describes that maximal number of iterations that the threshold is progressively increased per scanning phase.  It is recommended that the user select 1000. \n \n');
textbox_string = strcat(textbox_string, '\t Min Step Length:  This is a rejection criteria established to lend confidence for the minimum period of time (frames) a step must persist to be confidently classified as a step.   \n \n');
textbox_string = strcat(textbox_string,'\t Frame rate:  The time period the camera collects photons of light per image.  Units of frames per second (default to 10 frames per second). \n \n');
textbox_string = strcat(textbox_string, '\t Confidence:  Is the statistical parameter Confidence Level, which is the percentage of possible samples that can be expected to include the true parameter that is describing the data. \n \n');
textbox_string = strcat(textbox_string, '\t Step Size Deviation:  Throughout a trace, each step will have variable sizes as a result of random noise, simultaneous photobleaching events, background, etc.  This parameter describes the tolerable step intensity change within a single trace as a function of multiples of the average step size value. \n \n');

s = sprintf(textbox_string);

h = msgbox(s,'Help');



function tb_numbinsstep_Callback(hObject, eventdata, handles)
% hObject    handle to tb_numbinsstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_numbinsstep as text
%        str2double(get(hObject,'String')) returns contents of tb_numbinsstep as a double


% --- Executes during object creation, after setting all properties.
function tb_numbinsstep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_numbinsstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tb_numbinssnr_Callback(hObject, eventdata, handles)
% hObject    handle to tb_numbinssnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_numbinssnr as text
%        str2double(get(hObject,'String')) returns contents of tb_numbinssnr as a double


% --- Executes during object creation, after setting all properties.
function tb_numbinssnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_numbinssnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tb_indeter_Callback(hObject, eventdata, handles)
% hObject    handle to tb_indeter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tb_indeter as text
%        str2double(get(hObject,'String')) returns contents of tb_indeter as a double


% --- Executes during object creation, after setting all properties.
function tb_indeter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tb_indeter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
