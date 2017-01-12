

function varargout = AboutMRiLab(varargin)
% ABOUTMRILAB MATLAB code for AboutMRiLab.fig
%      ABOUTMRILAB, by itself, creates a new ABOUTMRILAB or raises the existing
%      singleton*.
%
%      H = ABOUTMRILAB returns the handle to a new ABOUTMRILAB or the handle to
%      the existing singleton*.
%
%      ABOUTMRILAB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ABOUTMRILAB.M with the given input arguments.
%
%      ABOUTMRILAB('Property','Value',...) creates a new ABOUTMRILAB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AboutMRiLab_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AboutMRiLab_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AboutMRiLab

% Last Modified by GUIDE v2.5 28-Apr-2013 18:36:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AboutMRiLab_OpeningFcn, ...
                   'gui_OutputFcn',  @AboutMRiLab_OutputFcn, ...
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


% --- Executes just before AboutMRiLab is made visible.
function AboutMRiLab_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AboutMRiLab (see VARARGIN)

% Choose default command line output for AboutMRiLab
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AboutMRiLab wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AboutMRiLab_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
