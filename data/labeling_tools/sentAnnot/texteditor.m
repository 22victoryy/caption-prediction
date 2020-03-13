function varargout = texteditor(varargin)
% code by Chen Kong, CMU

% Begin initialization code - DO NOT EDIT
dataset_globals;
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @texteditor_OpeningFcn, ...
                   'gui_OutputFcn',  @texteditor_OutputFcn, ...
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



% --- Executes just before texteditor is made visible.
function texteditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to texteditor (see VARARGIN)

% Choose default command line output for texteditor
%set(handles.figure1,'Units','pixels');
%figsz = get(handles.figure1,'Position');
%scrsz = get(0,'ScreenSize');
%figsz(1:2)= (scrsz(3:4)/2)-(figsz(3:4)/2);
%set(handles.figure1,'Position',figsz);
handles.output = 0;
if 0
%Im(:,:,:,1)=imread('texteditor.tif');
%Im(:,:,:,2)=Im(:,:,:,1);
%axis square off
%imshow(Im(:,:,:,1))
%handles.M=immovie(Im);
%set(handles.Frameslider,'Min',1);
%set(handles.Frameslider,'Max',2);
set(handles.Frameslider,'Value',1);
else
    % load first text
    dataset_globals;
    dest = input('annotator''s name: ', 's');
%     to_plan = input('use plan?Y/N','s');
%     if to_plan == 'Y' || to_plan == 'y'
%         handles.to_plan = 1;
%     else
        handles.to_plan = 0;
%     end
    user = 'info';
    user_dir = sprintf(SENT_USER, user);
    if ~exist(user_dir, 'dir')
        cmd = sprintf('scp -r %s %s', SENT_DIR, user_dir);
        unix(cmd);
    end;
    handles.user = user;
    handles.dest = dest;
    im_num = 1;
    handles.im_num = im_num;
    im_name = MY_IM_NUM(im_num);
    
    
    kc.obj_cls = load(fullfile(DATASET_ROOT, 'classes_reduced.mat'));
    handles.obj_cls = kc.obj_cls.classes;
    kc.sce_cls = load(fullfile(DATASET_ROOT, 'scene_classes.mat'));
    handles.sce_cls = kc.sce_cls.classes';
    
%imdata = load(fullfile(LABEL_DIR, sprintf('s%04d.mat', im_name)));
classfile = fullfile(SENT_DIR, 'classlist.mat');
if ~exist(classfile, 'file')
    try
        datafile = fullfile(DATASET_ROOT, 'classes_final');
        data = load(datafile);
        classes = data.classes;
        save(classfile, 'classes');
    catch
       classes = get(handles.hClassList, 'String');
       save(classfile, 'classes');
    end;
end;
data = load(classfile);
%handles.listboxtext = data.classes;
handles.classfile = classfile;
% if isstruct(imdata)
    set(handles.Frameslider,'Value',1);
    set(handles.Frameslider,'Min',1);
    set(handles.Frameslider,'Max',length(MY_IM_NUM));
    set(handles.Frameedit,'String','1');
  %  set(handles.Cutfromedit,'String','1');
  %  set(handles.Cuttoedit,'String',num2str(maxframe(2)));
    set(handles.hNumFrames, 'String', sprintf('/   %d', length(MY_IM_NUM)));
    handles = setSlider(handles, length(MY_IM_NUM));
    handles = plotCurrentSlider(handles);
   % set(handles.hSlider,'Max',length(MY_IM_NUM));
    handles = loadfile(handles, im_name);
    
      set(handles.hNumDesc, 'string',num2str(numel(handles.annotation.descriptions)));
      set(handles.hCurDesc, 'string',num2str(handles.desc_num));
     handles = generateSentenceButtons(handles);
    %handles = plotCurrentSlider(handles);
%     handles = plotstats(handles);
% end 
end;

% Update handles structure
guidata(handles.hTextObj, handles);

% UIWAIT makes texteditor wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function handles = plotCurrentSlider(handles)

val = getFrameNum(handles);
if isfield(handles, 'hCurSlider')
    try
        delete(handles.hCurSlider); 
    end;
end;
hold(handles.hSlider, 'on');
h = plot(handles.hSlider, val, 0.5, 'v', 'MarkerSize', 11, 'MarkerFaceColor', [0,0.5,1], 'MarkerEdgeColor', [0,0,1]);
handles.hCurSlider = h;
hold(handles.hSlider, 'off');

% --- Outputs from this function are returned to the command line.
function varargout = texteditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function Frameedit_Callback(hObject, eventdata, handles)
% hObject    handle to Frameedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Frameedit as text
%        str2double(get(hObject,'String')) returns contents of Frameedit as a double
%val = getFrameNum(handles);
val = [];
try
    val = get(handles.Frameedit, 'String');
    val = round(str2num(val));
end;
if isnumeric(val) & length(val)==1 & ...
    val >= get(handles.Frameslider,'Min') & ...
    val <= get(handles.Frameslider,'Max')
    dataset_globals;
    
    set(handles.Frameslider,'Value',val);
    handles = plotCurrentSlider(handles);
    set(handles.Frameedit,'String',num2str(val));
    
    im_name = MY_IM_NUM(val);
    handles.im_num = val;
    handles = loadfile(handles, im_name);
    handles = generateSentenceButtons(handles);
    guidata(hObject, handles);
else
    set(handles.Frameedit,'String',num2str(round(get(handles.Frameslider,'Value'))));
end


% --- Executes during object creation, after setting all properties.
function Frameedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Frameedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function Frameslider_Callback(hObject, eventdata, handles)
% hObject    handle to Frameslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = getFrameNum(handles);
dataset_globals;
im_name = MY_IM_NUM(val);
handles.im_num = val;
handles = plotCurrentSlider(handles);
set(handles.Frameedit,'String',num2str(val));
handles = loadfile(handles, im_name);
% handles = plotstats(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Frameslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Frameslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in SaveAnnotation.
function SaveAnnotation_Callback(hObject, eventdata, handles)
handles = guidata(handles.hTextObj);
% hObject    handle to SaveAnnotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%saveframe(handles.M,round(get(handles.Frameslider,'Value')));
% annotation = handles.annotation;
% fprintf('saving annotation file: %s\n', handles.annotfile);
% handles.oldannotation = annotation;
% % handles = plotstats(handles, 0);
dataset_globals;
destdir = fullfile(sprintf(SENT_USER,handles.dest));
if ~exist(destdir, 'dir')
    mkdir(destdir);
end
%destfile = fullfile(destdir, sprintf('gt%04d_%d.mat',handles.im_num, handles.desc_num));
destfile = fullfile(destdir, sprintf('gt%04d.mat',handles.im_num));
noun = handles.noun;%#ok<NASGU>
prep = handles.prep;%#ok<NASGU>
verb = handles.verb;%#ok<NASGU>
class = handles.class;%#ok<NASGU>
version = 1.04;%#ok<NASGU>
save(destfile, 'noun','prep','verb','class','version');
if handles.to_plan
    update_history(handles);
end
guidata(handles.hTextObj, handles);


function update_history(handles)
dataset_globals;
history = load(history_file);
isce = handles.im_num;
labeled = history.labeled; 
to_label = history.to_label; 
rm = find(to_label == isce);
if isempty(rm)
    error('a wrong label plan');
end
to_label = to_label([1:rm-1,rm+1:end]); %#ok<NASGU>
labeled = [labeled, isce]; %#ok<NASGU>
save(history_file, 'labeled', 'to_label');



% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function openmovie_Callback(hObject, eventdata, handles)
% hObject    handle to openmovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
M2=openmovie;
imdata.image = M2;
    handles.M=imdata;
    set(handles.Frameslider,'Value',1);
    set(handles.Frameslider,'Max',1);
    set(handles.Frameedit,'String','1');
    axes(handles.axes2);
    imshow(handles.M.image)
    set(handles.hSlider,'XLim',[1,1]);
    set(handles.hSlider,'XTick',[1: 1: 1]);
    set(handles.hSlider,'XTickLabel','');
    guidata(hObject, handles);


% --------------------------------------------------------------------
function savemovie_Callback(hObject, eventdata, handles)
% hObject    handle to savemovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
savemovie(handles.M);


% --------------------------------------------------------------------
function saveframe_Callback(hObject, eventdata, handles)
% hObject    handle to saveframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveframe(handles.M,round(get(handles.Frameslider,'Value')));


% --------------------------------------------------------------------
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);



% --------------------------------------------------------------------
function edit_Callback(hObject, eventdata, handles)
% hObject    handle to edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in prev.
function prev_Callback(hObject, eventdata, handles)
% hObject    handle to prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
handles = guidata(handles.hTextObj);
if ~handles.to_plan
    dataset_globals;
    im_num = handles.im_num;
    im_num = mod(im_num - 2, length(MY_IM_NUM)) + 1;
    im_name = MY_IM_NUM(im_num);
    handles.im_num = im_num;
    %if isstruct(M2)
        %set(handles.Frameslider,'Value',1);
        %set(handles.Frameslider,'Min',1);
        %set(handles.Frameslider,'Max',maxframe(2));
    set(handles.Frameedit,'String',sprintf('%04d', im_num));
        %set(handles.Cutfromedit,'String','1');
        %set(handles.Cuttoedit,'String',num2str(maxframe(2)));
        %set(handles.hNumFrames, 'String', sprintf('/   %d', maxframe(2)));
    %     set(handles.hDesc, 'String', '');
        %handles = setSlider(handles, maxframe);
    handles = plotCurrentSlider(handles);
    handles = loadfile(handles, im_name);
    handles = generateSentenceButtons(handles);   
    %     handles = plotstats(handles);
    guidata(handles.hTextObj, handles); 
end


% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(handles.hTextObj);
    dataset_globals;
    im_num = handles.im_num;
    if handles.to_plan
        dataset_globals;
        history = load(history_file);
        im_num = history.to_label(1);
    else
        im_num = mod(im_num, length(MY_IM_NUM)) + 1;
    end
    im_name = MY_IM_NUM(im_num);
    handles.im_num = im_num;
%if isstruct(M2)
    %set(handles.Frameslider,'Value',1);
    %set(handles.Frameslider,'Min',1);
    %set(handles.Frameslider,'Max',maxframe(2));
    set(handles.Frameedit,'String',sprintf('%04d', im_num));
    %set(handles.Cutfromedit,'String','1');
    %set(handles.Cuttoedit,'String',num2str(maxframe(2)));
    %set(handles.hNumFrames, 'String', sprintf('/   %d', maxframe(2)));
%    set(handles.hDesc, 'String', '');
    %handles = setSlider(handles, maxframe);
    handles = plotCurrentSlider(handles);
    handles = loadfile(handles, im_name);
    handles = generateSentenceButtons(handles);
%     handles = plotstats(handles);
    guidata(handles.hTextObj, handles); 
%end

fprintf('loaded\n');

function handles = setSlider(handles, maxframe)

    set(handles.hSlider,'XLim',[0.5,maxframe+0.5]);
    set(handles.hSlider,'XTick',[1: floor(maxframe / 15): maxframe]);
    set(handles.hSlider,'XTickLabel','');


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

annotation = handles.annotation;
numdesc = length(annotation.descriptions)+1;
desc_num = numdesc;
fprintf('adding description: %d\n', desc_num);
txt = get(handles.hDesc, 'String');
for i = 1 : length(annotation.descriptions)
    if strcmp(annotation.descriptions(i).text, txt)
        set(handles.hDesc, 'String', '')
    end;
end;
handles.annotation.descriptions(desc_num).text = get(handles.hDesc, 'String');
words = splitSentence(handles.annotation.descriptions(desc_num).text);
handles.annotation.descriptions(desc_num).words = words;
    if ~isfield(handles.annotation.descriptions(desc_num), 'obj_id')
        handles.annotation.descriptions(desc_num).obj_id = cell(length(words), 1);
    end;
    if length(handles.annotation.descriptions(desc_num).obj_id) < length(words)
        n = length(handles.annotation.descriptions(desc_num).obj_id);
        handles.annotation.descriptions(desc_num).obj_id = [handles.annotation.descriptions(desc_num).obj_id; cell(length(words) - n, 1)]; 
    end;
handles.desc = get(handles.hDesc, 'String');
handles.desc_num = desc_num;
% handles = plotstats(handles);
guidata(hObject, handles);



% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    set(handles.hDescTo,'String',...
        num2str(round(get(handles.Frameslider,'Value'))))
    if round(str2num(get(handles.hDescFrom, 'String')))>...
        round(str2num(get(handles.hDescTo, 'String')))
        set(handles.hDescFrom,'String',round(str2num(get(handles.hDescTo, 'String'))))
    end;
    desc_num = handles.desc_num;
    if desc_num > 0
       handles.annotation.descriptions(desc_num).text = get(handles.hDesc, 'String');
       handles.annotation.descriptions(desc_num).from = round(str2num(get(handles.hDescFrom, 'String')));
       handles.annotation.descriptions(desc_num).to = round(str2num(get(handles.hDescTo, 'String')));
       words = splitSentence(handles.annotation.descriptions(desc_num).text);
       handles.annotation.descriptions(desc_num).words = words;
       fprintf('Description   %d  updated\n', desc_num);
    end;
    handles = plotCurrentSlider(handles);
    plottimers(handles, handles.annotation)
%     handles = plotstats(handles);
    guidata(hObject, handles);


function hDescFrom_Callback(hObject, eventdata, handles)
% hObject    handle to hDescFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hDescFrom as text
%        str2double(get(hObject,'String')) returns contents of hDescFrom as a double


% --- Executes during object creation, after setting all properties.
function hDescFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hDescFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%if round(get(handles.Frameslider,'Value'))<=...
%        str2double(get(handles.hDescTo,'String'))
    set(handles.hDescFrom,'String',...
        num2str(round(get(handles.Frameslider,'Value'))))
    if round(str2num(get(handles.hDescFrom, 'String')))>...
        round(str2num(get(handles.hDescTo, 'String')))
        set(handles.hDescTo,'String',round(str2num(get(handles.hDescFrom, 'String'))))
    end;
   desc_num = handles.desc_num;
   if desc_num > 0
      handles.annotation.descriptions(desc_num).text = get(handles.hDesc, 'String');
      handles.annotation.descriptions(desc_num).from = round(str2num(get(handles.hDescFrom, 'String')));
      handles.annotation.descriptions(desc_num).to = round(str2num(get(handles.hDescTo, 'String')));
      words = splitSentence(handles.annotation.descriptions(desc_num).text);
      handles.annotation.descriptions(desc_num).words = words;
      fprintf('Description   %d  updated\n', desc_num);
   end;
   handles = plotCurrentSlider(handles);
   plottimers(handles, handles.annotation)
%    handles = plotstats(handles);
   guidata(hObject, handles);
%end


function hDesc_Callback(hObject, eventdata, handles)
% hObject    handle to hDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hDesc as text
%        str2double(get(hObject,'String')) returns contents of hDesc as a double


% --- Executes during object creation, after setting all properties.
function hDesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
annotation = handles.annotation;
desc_num = handles.desc_num;
if desc_num > 0 && desc_num <= length(annotation.descriptions)
    ind = setdiff([1 : length(annotation.descriptions)]', desc_num);
    if ~isempty(ind)
        annotation.descriptions = annotation.descriptions(ind);
        if desc_num > length(ind)
            desc_num = length(ind);
        end;
    else
        annotation.descriptions = [];
        desc_num = 0;
    end;
    handles.annotation = annotation;
    if desc_num > 0
       set(handles.hDesc, 'String', annotation.descriptions(desc_num).text)
    else
       set(handles.hDesc, 'String', '')
    end;
    handles.desc = get(handles.hDesc, 'String');
    handles.desc_num = desc_num;

%     handles = plotstats(handles);
    guidata(hObject, handles);
end;


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.hTextObj);
annotation = handles.annotation;
numdesc = length(annotation.descriptions);
desc_num = handles.desc_num;
desc_num = mod(desc_num - 2, numdesc) + 1;
if desc_num > numdesc
    desc_num = 0;
end;
desc = '';
if desc_num
    desc = annotation.descriptions(desc_num).text;
%    set(handles.hDesc, 'String', desc);
end;
handles.desc = desc;
handles.desc_num = desc_num;
    handles = generateSentenceButtons(handles);
% handles = plotstats(handles);
guidata(handles.hTextObj, handles);


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.hTextObj);
annotation = handles.annotation;
numdesc = length(annotation.descriptions);
desc_num = handles.desc_num;
desc_num = mod(desc_num, numdesc) + 1;
if desc_num > numdesc
    desc_num = 0;
end;
desc = '';
 if desc_num
     desc = annotation.descriptions(desc_num).text;
%     set(handles.hDesc, 'String', desc);
 end;
handles.desc = desc;
handles.desc_num = desc_num;
handles = generateSentenceButtons(handles);
% handles = plotstats(handles);
guidata(handles.hTextObj, handles);


% --- Executes on key press with focus on playbutton and none of its controls.
function playbutton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to playbutton (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if 0
userdata = get(hObject, 'UserData');
userdata = 1 - userdata;
set(hObject, 'UserData', userdata);
if userdata == 1
    set(hObject, 'String', 'PLAY');
else
    set(hObject, 'String', 'PAUSE');
end;
end;


% --- Executes during object creation, after setting all properties.
function hNumFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hNumFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function handles = loadfile(handles, num)

dataset_globals;
handles.noun = []; handles.prep = []; handles.class = []; handles.verb = [];    
% set(handles.hVideoName, 'String', sprintf('%04d', num));
dataset_globals;
if ~isfield(handles, 'user')
   annotfile = fullfile(SENT_DIR, sprintf('%04d.mat', num));
else
    user_dir = sprintf(SENT_USER, handles.user);
    annotfile = fullfile(user_dir, sprintf('in%04d.mat', num));
    
end;
if ~exist(annotfile, 'file')
    annotation.name =  sprintf('%04d', num);
    %annotation.num_frames = get(handles.Frameslider,'Max');
    annotation.descriptions = [];
    fprintf('saving annotation file: %s\n', annotfile);
    save(annotfile, 'annotation')
    fprintf('# of descriptions: %d\n', length(annotation.descriptions));
else
    annotation = load(annotfile);
    
%     fprintf('# of descriptions: %d\n', length(annotation.descriptions));
end;

% if ~isfield(annotation, 'class')
%     annotation.class = [];
% end;
% if ~isfield(annotation, 'bboxes')
%    annotation.bboxes = zeros(length(annotation.class), 4);
% end;
% if ~isfield(annotation, 'truncated')
%    annotation.truncated = cell(length(annotation.class), 1);
% end;
% if ~isfield(annotation, 'occluded')
%    annotation.occluded = cell(length(annotation.class), 1);
% end;
% if ~isfield(annotation, 'seg')
%    annotation.seg = cell(length(annotation.class), 1);
% end;
% if ~isfield(annotation, 'box3D')
%    annotation.box3D = cell(length(annotation.class), 1);
% end;
% if ~isfield(annotation, 'boxView')
%    annotation.boxView = cell(length(annotation.class), 1);
% end;
% if ~isfield(annotation, 'angle')
%    annotation.angle = cell(length(annotation.class), 1);
% end;
% %save(annotfile, 'annotation')
% if isfield(handles, 'obj_num')
%     obj_num = handles.obj_num;
% else
%     handles.obj_num = min(length(annotation.class), 1);
%     obj_num = handles.obj_num;
% end;
   
handles.annotation = annotation;
handles.annotfile = annotfile;
% handles.oldannotation = annotation;
if isfield(annotation, 'descriptions') && length(annotation.descriptions) >= 1
    handles.desc_num = 1;
else
    handles.desc_num = 0;
end;
% if handles.desc_num
%     desc = annotation.descriptions(handles.desc_num).text;
%     %set(handles.hDesc, 'String', desc);
% end;
% handles.obj_num = obj_num;
% handles = plotstats(handles);
destdir = fullfile(sprintf(SENT_USER,handles.dest));
%destfile = fullfile(destdir, sprintf('gt%04d_%d.mat',handles.im_num, handles.desc_num));
destfile = fullfile(destdir, sprintf('gt%04d.mat',handles.im_num));
if exist(destfile, 'file')
   data = load(destfile);
   handles.noun = data.noun; 
   handles.prep = data.prep;
   handles.verb = data.verb;
   handles.class = data.class;
   handles.annotation.descriptions(handles.desc_num).prep = data.prep;
   %handles.annotation.descriptions(handles.desc_num).class = data.class;
   %handles.annotation.descriptions(handles.desc_num).verb = data.verb;
   %handles.annotation.descriptions(handles.desc_num).noun = data.noun;
end;

function plotline(handles, from, to, col, lw)

    plot(handles.hSlider,[from, from]', [0.2, 0.8]', '-', 'Color', col, 'linewidth', lw)
    plot(handles.hSlider,[to, to]', [0.2, 0.8]', '-', 'Color', col, 'linewidth', lw)
    plot(handles.hSlider,[from, to]', [0.5, 0.5]', '-', 'Color', col, 'linewidth', lw)


% --- Executes on key press with focus on hDesc and none of its controls.
function hDesc_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to hDesc (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

%fprintf('%s  ', get(handles.figure1,'CurrentCharacter'));
% %fprintf('%d  \n', int16(get(handles.figure1,'CurrentCharacter')));
% if int16(get(handles.figure1,'CurrentCharacter'))==13
%    desc_num = handles.desc_num;
%    if desc_num > 0
%        drawnow;
%       oldtext = handles.annotation.descriptions(desc_num).text;
%       handles.annotation.descriptions(desc_num).text = get(handles.hDesc, 'String');
%       newtext = handles.annotation.descriptions(desc_num).text;
%       %fprintf('%s\n', get(handles.hDesc, 'String'))
%       %fprintf('%s\n', handles.annotation.descriptions(desc_num).text);
%       if ~strcmp(oldtext, newtext)
%          fprintf('Description   %d  updated\n', desc_num);
%       end;
%       words = splitSentence(handles.annotation.descriptions(desc_num).text);
%       handles.annotation.descriptions(desc_num).words = words;
%       handles = plotstats(handles);
%    end;
%    guidata(hObject, handles);
% end;
return;


% --- Executes on button press in hUpdate.
function hUpdate_Callback(hObject, eventdata, handles)
% hObject    handle to hUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
%    desc_num = handles.desc_num;
%    if desc_num > 0
%       handles.annotation.descriptions(desc_num).text = get(handles.hDesc, 'String');
%       words = splitSentence(handles.annotation.descriptions(desc_num).text);
%       handles.annotation.descriptions(desc_num).words = words;
%       %fprintf('%s\n', get(handles.hDesc, 'String'))
%       %fprintf('%s\n', handles.annotation.descriptions(desc_num).text);
%       fprintf('Description   %d  updated\n', desc_num);
%       handles = plotstats(handles);
%    end;
%    guidata(hObject, handles);
return;


% --- Executes on mouse press over axes background.
function hSlider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to hSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

return;
pp = get(hObject, 'CurrentPoint');

x = pp(1);

if 1%abs(pp(2) - 0.5) < 10
    annotation = handles.annotation;
    n = length(annotation.descriptions);
    isin = zeros(n, 2);
    for i = 1 : n
        from  = annotation.descriptions(i).from;
        to  = annotation.descriptions(i).to;
        if x >= from - 1 && x <= to + 1
            isin(i, 1) = 1;
            isin(i, 2) = abs(0.5 * (from + to) - x);
        end;
    end;
    ind = find(isin(:, 1));
    if length(ind) >= 1
        [m, m_ind] = min(isin(ind, 2));
        ind = ind(m_ind);
        handles.desc_num = mod(ind-2, length(annotation.descriptions)) + 1;
%         handles = plotstats(handles);
        guidata(hObject, handles);
        pushbutton19_Callback(handles.pushbutton19, [], handles)
    end;
end;


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataset_globals;
val = getFrameNum(handles);
val = mod(val - 2, get(handles.Frameslider,'Max')) + 1;
im_name = MY_IM_NUM(val);
handles = loadfile(handles, im_name);
set(handles.Frameslider,'Value', val)
handles = plotCurrentSlider(handles);
set(handles.Frameedit,'String',num2str(val));
% handles = plotstats(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataset_globals;
val = getFrameNum(handles);
val = mod(val, get(handles.Frameslider,'Max')) + 1;
im_name = MY_IM_NUM(val);
handles = loadfile(handles, im_name);
set(handles.Frameslider,'Value', val)
handles = plotCurrentSlider(handles);
set(handles.Frameedit,'String',num2str(val));
% handles = plotstats(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

obj_num = handles.obj_num;
obj_num_old = obj_num;
obj_num = mod(obj_num - 2, size(handles.annotation.bboxes, 1)) + 1;
handles.obj_num = obj_num;
if obj_num > size(handles.annotation.bboxes, 1)
    obj_num = 0;
end;
if obj_num~=obj_num_old
%    handles = plotstats(handles);
   guidata(hObject, handles);
end;

% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

obj_num = handles.obj_num;
obj_num_old = obj_num;
obj_num = mod(obj_num, size(handles.annotation.bboxes, 1)) + 1;
handles.obj_num = obj_num;
if obj_num > size(handles.annotation.bboxes, 1)
    obj_num = 0;
end;
if obj_num~=obj_num_old
%    handles = plotstats(handles);
   guidata(hObject, handles);
end;


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = addobject(handles);

% handles = plotstats(handles);
guidata(hObject, handles);
fprintf('object added\n');
   
   
function handles = addobject(handles)

annotation = handles.annotation;
n = size(annotation.bboxes, 1) + 1;
annotation.bboxes(n, 1:4) = zeros(1, 4);
annotation.truncated(n) = 0;
annotation.occluded(n) = 0;
annotation.seg{n} = [];
annotation.class{n} = get(handles.hClass, 'String');
annotation.box3D{n} = [];
annotation.boxView{n} = [];
annotation.angle(n,:) = Inf;
handles.annotation = annotation;
handles.obj_num = n;

function ids = getObjectIds(annotation)

ids = [];
for i = 1 : length(annotation.object_id)
   ids_i = annotation.object_id{i};
    if ~isempty(ids_i)

       ids = union(ids, ids_i);
    end;
end;
ind = find(ids > 0);
ids = ids(ind);

function m = getNewId(ids)

m = max(ids);
id = setdiff([1:m+1]', ids);
m = min(id);

% --- Executes on button press in pushbutton27
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

obj_num = handles.obj_num;
n = size(handles.annotation.bboxes, 1);
if obj_num > 0 && obj_num <= n
    handles.annotation.bboxes(obj_num, :) = [];
    handles.annotation.occluded(obj_num, :) = [];
    handles.annotation.truncated(obj_num, :) = [];
    handles.annotation.seg = handles.annotation.seg(setdiff([1:n]', obj_num));
    handles.annotation.class = handles.annotation.class(setdiff([1:n]', obj_num));
    handles.annotation.box3D = handles.annotation.box3D(setdiff([1:n]', obj_num));
    handles.annotation.boxView = handles.annotation.boxView(setdiff([1:n]', obj_num));
    handles.annotation.angle(obj_num, :) = [];
    if obj_num > size(handles.annotation.bboxes, 1)
        obj_num = size(handles.annotation.bboxes, 1);
    end;
    handles.obj_num = obj_num;
%     handles = plotstats(handles);
    guidata(hObject, handles);
end;

function val = getFrameNum(handles)

val = round(get(handles.Frameslider, 'Value'));
if val < 1, val = 1; end;
if val > get(handles.Frameslider, 'Max')
    val = get(handles.Frameslider, 'Max');
end;

function hId_Callback(hObject, eventdata, handles)
% hObject    handle to hId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hId as text
%        str2double(get(hObject,'String')) returns contents of hId as a double

val = getFrameNum(handles);
obj_num = handles.obj_num;
if obj_num == 0 || obj_num > size(handles.annotation.bboxes{val}, 1)
    return;
end;
num = 0;
try
num = str2num(get(handles.hId, 'String'));
num = round(num);
catch
    fprintf('must be an integer\n');
end;

handles.annotation.object_id{val}(obj_num, :) = 0;
ids = getObjectIds(handles.annotation);
id = getNewId(ids);

if num ==0 || num > max(ids) + 1
    num = id;
end;

set(handles.hId, 'String', sprintf('%d', num));
handles.annotation.object_id{val}(obj_num, :) = num;
handles = getClassOfObjId(handles, val, obj_num);
% handles = plotstats(handles);
guidata(hObject, handles);

function handles = getClassOfObjId(handles, val, obj_num)

annotation = handles.annotation;
id = annotation.object_id{val}(obj_num);
if id == 0
    return;
end;
annotation.object_id{val}(obj_num) = 0;
cls = [];
for i = 1 : length(annotation.object_id)
    ind = find(annotation.object_id{i} == id);
    if ~isempty(ind)
        cls = annotation.class{i}{ind(1)};
        break;
    end;
end;
annotation.object_id{val}(obj_num) = id;
if ~isempty(cls)
    set(handles.hClass, 'String', cls);
    annotation.class{val}{obj_num} = cls;
    handles.annotation = annotation;
end;

% --- Executes during object creation, after setting all properties.
function hId_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in hClear.
function hClear_Callback(hObject, eventdata, handles)
% hObject    handle to hClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

desc_num = handles.desc_num;
if desc_num ==0 || desc_num > length(handles.annotation.descriptions)
    return;
end;
try
n = length(handles.annotation.descriptions(desc_num).words);
catch
    n = 0;
end;
handles.annotation.descriptions(desc_num).obj_id = cell(n, 1);
handles = settextbuttons(handles);
% handles = plotstats(handles, 0);
guidata(hObject, handles);


% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.hTextObj);
handles.annotation = handles.oldannotation;
% handles = plotstats(handles);
guidata(handles.hTextObj, handles);

function handles = generateSentenceButtons(handles)

if ~isfield(handles, 'hsentences')
    handles.hsentences = [];
end;
 numde = numel(handles.annotation.descriptions);
 set(handles.hNumDesc,'string',num2str(numde));
 set(handles.hCurDesc,'string',num2str(handles.desc_num));
handles = settextbuttons(handles);
guidata(handles.hTextObj, handles);




% --- Executes on button press in hcardupd.
function hcardupd_Callback(hObject, eventdata, handles)
% hObject    handle to hcardupd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.hTextObj);
% set(hObject, 'String','Recompute');
allh = get(handles.hcard,'children');
for ih = 1:numel(allh)
    if allh(ih) ~= hObject;
        delete(allh(ih));
    end
end
noun = handles.noun;
class = {};
for i =1:numel(noun);
    if noun{i}.isnoun
        if isempty(class)
            class.name = noun{i}.cls;
            class.card = 1;
        else
            flg = 0;
            for j = 1:numel(class)
                if strcmp(class(j).name, noun{i}.cls)
                    class(j).card = class(j).card + 1;
                    flg = 1;
                end
            end
            if ~flg
                class(j+1).name = noun{i}.cls;
                class(j+1).card = 1;
            end
        end            
    end
end
set(hObject,'Units','pixels');
text_pos = get(hObject,'position');
toppos =  text_pos(2);
lwidth = 16;
left = text_pos(1);
hpos = toppos - lwidth - 5;
fontsize = 10;
ann = cell(numel(class),1);
for i = 1 : length(ann), ann{i} = zeros(2, 1); end;
for iann = 1:numel(class)
    ann{iann}(1) = uicontrol('Style','text','string','word1','Parent', handles.hcard,'Fontsize',fontsize+0.4, ...
        'ForegroundColor', [0,0,0],...
        'backgroundcolor',[0.96,0.92,0.92]);
    ann{iann}(2) = uicontrol('Style','edit','string','word1','Parent', handles.hcard,'Fontsize',fontsize+0.4, ...
        'ForegroundColor', [0,0,0],'Callback', {@cardcallbackfcn, handles});
    set(ann{iann}(1), 'position', [left, hpos, 60, 14],'string',class(iann).name);
    set(ann{iann}(2), 'position', [left+80, hpos, 60, 20],'string',num2str(class(iann).card));
    hpos = hpos - lwidth;
end
for i = 1:numel(ann)
    for j = 1 : numel(ann{i})
        if ann{i}(j)
            ind = zeros(size(ann{1}, 1), 1);
            ind(j) = 1;
            idn = ones(size(ann{1}, 1), 1);
            idn = idn * i;
            set(ann{i}(j), 'UserData', [ann{i}, ind, idn]);
        end;
    end;
end
handles.class = class;
guidata(handles.hTextObj, handles);


% --- Executes on button press in hclear.
function hclear_Callback(hObject, eventdata, handles)
% hObject    handle to hclear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.hTextObj);
handles = generateSentenceButtons(handles);
%     handles = plotstats(handles);
    guidata(handles.hTextObj, handles); 

function cardcallbackfcn(hObject, EventData, handles)
handles = guidata(handles.hTextObj);
desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
strnum = get(allh(ind,1),'String');
num = str2num(strnum);
handles.class(allh(1,3)).card = num;
% handles = plotstats(handles, 0);
%handles.sel_obj = sel_obj;
guidata(handles.hTextObj, handles);
