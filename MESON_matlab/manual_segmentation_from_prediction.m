%function to do the manual segmentation from the predicted volume varargin
%is a struct
%parameters to run the function
%varargin.file_path < A cell indicating the path to the folder containing the raw
%and predicted volumes

%varargin.file_raw < A cell indicating the name of the raw volumes

%varargin.file_predicted < A cell indicating the name of the predicted volumes

%varargin.file_seg_output < A cell indicating the name of the output for
%the segmentation

%varargin.percentage_threshold_intensity <- value indicating the percentage to
%detect thick structures

%varargin.min_c <- an array indicating the maximu size of connected component to be
%removed for each stack

%example
% p.file_path = {'C:\my volume\stack1' 'C:\my volume\stack2'};
% p.file_raw = {'stack1' 'stack2'};
% p.file_predicted = {'predicted_stack1' 'predicted_stack2'};
% p.file_seg_output = {'segmentation_stack1' 'segmentation_stack2'};
% p.percentage_threshold_intensity = 0.9;
% p.min_c = [10^3 10^3];
% manual_segmentation_from_prediction(p)

function varargout = manual_segmentation_from_prediction(varargin)
% MANUAL_SEGMENTATION_FROM_PREDICTION MATLAB code for manual_segmentation_from_prediction.fig
%      MANUAL_SEGMENTATION_FROM_PREDICTION, by itself, creates a new MANUAL_SEGMENTATION_FROM_PREDICTION or raises the existing
%      singleton*.
%
%      H = MANUAL_SEGMENTATION_FROM_PREDICTION returns the handle to a new MANUAL_SEGMENTATION_FROM_PREDICTION or the handle to
%      the existing singleton*.
%
%      MANUAL_SEGMENTATION_FROM_PREDICTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUAL_SEGMENTATION_FROM_PREDICTION.M with the given input arguments.
%
%      MANUAL_SEGMENTATION_FROM_PREDICTION('Property','Value',...) creates a new MANUAL_SEGMENTATION_FROM_PREDICTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manual_segmentation_from_prediction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manual_segmentation_from_prediction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manual_segmentation_from_prediction

% Last Modified by GUIDE v2.5 17-Jun-2022 18:35:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manual_segmentation_from_prediction_OpeningFcn, ...
                   'gui_OutputFcn',  @manual_segmentation_from_prediction_OutputFcn, ...
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


% --- Executes just before manual_segmentation_from_prediction is made visible.
function manual_segmentation_from_prediction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manual_segmentation_from_prediction (see VARARGIN)

% Choose default command line output for manual_segmentation_from_prediction
handles.output = hObject;

%default parameters
handles.min_c = 10^3;

%variable to check if data has been load
handles.data_open = false;

%value for segmentation
handles.threshold_segmentation = 0.5;

%to save the spacing
handles.spacing = [];

%to save the segmentation
handles.segmentation_3D = [];

%to save the MIP of the segmentation
handles.segmentation_projection = [];

set(handles.figure1, 'units', 'normalized', 'position', [0.05 0.05 0.9 0.9])

%disabling push button for segmentation
set(handles.save_segmentation_push_button,'Enable','off') 

%setting default values
set(handles.segmentation_threshold_box, 'string',num2str(handles.threshold_segmentation)); 
set(handles.min_connected_size_box,'string',num2str(handles.min_c^(1/3),'%5.2f')); 

% update_segmentation_push_button handles structure
guidata(hObject, handles);

% UIWAIT makes manual_segmentation_from_prediction wait for user response (see UIRESUME)
% uiwait(handles.figure1);



function handles = displayImage(axis_id, img, color_map)

axes(axis_id)
%display the image
imshow(img',[],'InitialMagnification','fit'); 
colormap(axis_id,color_map);colorbar;





% --- Outputs from this function are returned to the command line.
function varargout = manual_segmentation_from_prediction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function segmentation_threshold_box_Callback(hObject, eventdata, handles)
% hObject    handle to segmentation_threshold_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of segmentation_threshold_box as text
prev_threshold = handles.threshold_segmentation;
handles.threshold_segmentation = str2double(get(hObject,'String')); %returns contents of segmentation_threshold as a double

if (check_box_value_is_correct(handles.threshold_segmentation, prev_threshold) && handles.data_open )
    %make sure threshold is larger than 0
    if (handles.threshold_segmentation<0)
        handles.threshold_segmentation = 0;
        set(handles.segmentation_threshold_box, 'string',num2str(handles.threshold_segmentation)); 
    end
    
    %make sure threshold is smaller than 1
    if (handles.threshold_segmentation>1)
        handles.threshold_segmentation = 1;
        set(handles.segmentation_threshold_box, 'string',num2str(handles.threshold_segmentation)); 
    end    
    
    %doing the segmentation with the new threshold and given min_c
    handles.seg_3d = remove_small_conComp3D(handles.data.output_model > handles.threshold_segmentation, handles.min_c, 26);
    handles.seg_projection = max(handles.seg_3d,[],3);
    
    %update segmentation in figure 1 is segmentation radio button is
    %selected
    if (get(handles.fig1_segmentation, 'Value')==1)
        displayImage(handles.figure_display_1, handles.seg_projection, 'gray');
    end
    
    %update segmentation in figure 2 is segmentation radio button is
    %selected    
    if (get(handles.fig2_segmentation, 'Value')==1)
        displayImage(handles.figure_display_2, handles.seg_projection, 'gray');
    end        
        
end   
    
guidata(hObject,handles)

function validity = check_box_value_is_correct(current_val, prev_val)
validity = true;
if isnan(current_val)
    validity = false;
elseif (current_val==prev_val)
    validity = false;
end

        

% --- Executes during object creation, after setting all properties.
function segmentation_threshold_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segmentation_threshold_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function min_connected_size_box_Callback(hObject, eventdata, handles)
% hObject    handle to min_connected_size_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_connected_size_box as text

prev_min_c = handles.min_c;
handles.min_c =  str2double(get(hObject,'String'))^3;% returns contents of min_connected_size as a double

if (check_box_value_is_correct(handles.min_c, prev_min_c) && handles.data_open )
    %make sure min_c is larger than 0
    if (handles.min_c<0)
        handles.min_c = 0;
        set(handles.min_connected_size_box, 'string',num2str(0)); 
    end 
    
    %doing the segmentation with the new min_c value and  the given
    %threshold
    handles.seg_3d = remove_small_conComp3D(handles.data.output_model > handles.threshold_segmentation, handles.min_c, 26);
    handles.seg_projection = max(handles.seg_3d,[],3);
    
    %update segmentation in figure 1 is segmentation radio button is
    %selected    
    if (get(handles.fig1_segmentation, 'Value')==1)
        displayImage(handles.figure_display_1, handles.seg_projection, 'gray');
    end
    
    %update segmentation in figure 2 is segmentation radio button is
    %selected    
    if (get(handles.fig2_segmentation, 'Value')==1)
        displayImage(handles.figure_display_2, handles.seg_projection, 'gray');
    end    
        
end

 guidata(hObject,handles)
 
% --- Executes during object creation, after setting all properties.
function min_connected_size_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_connected_size_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in save_segmentation_push_button.
function save_segmentation_push_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_segmentation_push_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file_name,folder_path] = uiputfile('*.tif','Save segmentation', fullfile(handles.folder_path ,['segmentation_threshold_' num2str(handles.threshold_segmentation) '_min_conn_' num2str(handles.min_c) '.tif']));

if not(isequal(file_name,0))
    write_tif(uint8(255*handles.seg_3d),folder_path, file_name)    
end

        


% --- Executes on button press in open_file_push_button.
function open_file_push_button_Callback(hObject, eventdata, handles)
% hObject    handle to open_file_push_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%open a windows to select the mat file
[folder_name,folder_path] = uigetfile('*.mat');
if not(isequal(folder_name,0))
    %data has been loaded
    handles.data_open = true;
    handles.folder_path = folder_path;
    handles.folder_name = folder_name;
    
    %The user selected a file
    set(handles.save_segmentation_push_button,'Enable','on') ;
    
    %load_data
    handles.data = load(fullfile(folder_path, folder_name));
    
    %save the projections this does not change value
    handles.raw_projection = max(handles.data.img_3d_raw,[],3);
    handles.pred_projection = max(handles.data.output_model,[],3);
    
    handles.seg_3d = remove_small_conComp3D(handles.data.output_model > handles.threshold_segmentation, handles.min_c, 26);
    handles.seg_projection = max(handles.seg_3d, [], 3);
    
    
    %we use raw and prediction as the first images to display
    displayImage(handles.figure_display_1, handles.pred_projection, 'jet');
    set(handles.fig1_predicted, 'Value', 1);
    
    displayImage(handles.figure_display_2, handles.seg_projection, 'gray');
    set(handles.fig2_segmentation, 'Value', 1);
    
    %save data in handles
    guidata(hObject, handles);
end

%update 




% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.data_open
    switch get(eventdata.NewValue,'tag')
        case 'fig1_raw_img'
            img = handles.raw_projection; colormap_ = 'gray';
        case 'fig1_predicted'
            img = handles.pred_projection; colormap_ = 'jet';
        case 'fig1_segmentation'
            img = handles.seg_projection; colormap_ = 'gray';
    end
    displayImage(handles.figure_display_1, img, colormap_);
end


% --- Executes when selected object is changed in uibuttongroup2.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup2 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.data_open
    switch get(eventdata.NewValue,'tag')
        case 'fig2_raw_img'
            img = handles.raw_projection; colormap_ = 'gray';
        case 'fig2_predicted'
            img = handles.pred_projection; colormap_ = 'jet';
        case 'fig2_segmentation'
            img = handles.seg_projection; colormap_ = 'gray';
    end
    displayImage(handles.figure_display_2, img, colormap_);
end
