function handles = plotstats(handles, dosent)

if nargin < 2
    dosent = 1;
end;
if handles.obj_num > size(handles.annotation.bboxes, 1)
    handles.obj_num = size(handles.annotation.bboxes, 1);
end;
set(handles.hNumDesc, 'String', sprintf('%d', length(handles.annotation.descriptions)));
if handles.desc_num == 0
   set(handles.hCurDesc, 'String', 'None');
else
   set(handles.hCurDesc, 'String', sprintf('%d', handles.desc_num)); 
end;
if handles.obj_num == 0
    set(handles.hObjId, 'String', 'None')
    set(handles.hClass, 'String', '')
    set(handles.hObjNum, 'String', '0')
else
    set(handles.hObjId, 'String', sprintf('%d  /  %d', handles.obj_num, size(handles.annotation.bboxes, 1)));
    if handles.obj_num > 0 && handles.obj_num <= length(handles.annotation.class)
       set(handles.hClass, 'String', handles.annotation.class{handles.obj_num});
    end;
    set(handles.hObjNum, 'String', num2str(handles.obj_num))
end;

changed = 0;
if handles.obj_num > 0
    annotation = handles.annotation;
    oldannot = handles.oldannotation;
    if length(annotation.class) ~= length(oldannot.class)
        changed = 1;
    else
        col = annotation.color(handles.obj_num).name;
        bright = annotation.color(handles.obj_num).brightness;
        diff = annotation.color(handles.obj_num).difficult;
        cols = get(handles.hColor, 'String');
        ind = strmatch(col, cols, 'exact');
        set(handles.hColor, 'Value', ind);
        lightlist = get(handles.hLight, 'String');
        ind = strmatch(bright, lightlist, 'exact');
        set(handles.hLight, 'Value', ind);
        if diff
            set(handles.hColDiff, 'Value', 1)
        else
            set(handles.hColDiff, 'Value', 0)
        end;

        if ~strcmp(col, oldannot.color(handles.obj_num).name)
            changed = 1;
        end;
        if ~strcmp(bright, oldannot.color(handles.obj_num).brightness)
            changed = 1;
        end;
        if diff~=oldannot.color(handles.obj_num).difficult
            changed = 1;
        end;
        
        sz = annotation.size(handles.obj_num).name;
        diff = annotation.size(handles.obj_num).difficult;
        sizes = get(handles.hSize, 'String');
        ind = strmatch(sz, sizes, 'exact');
        set(handles.hSize, 'Value', ind);
        if diff
            set(handles.hSizeDiff, 'Value', 1)
        else
            set(handles.hSizeDiff, 'Value', 0)
        end;

        if ~strcmp(sz, oldannot.size(handles.obj_num).name)
            changed = 1;
        end;
        if diff~=oldannot.size(handles.obj_num).difficult
            changed = 1;
        end;
    end;
else
    cols = get(handles.hColor, 'String');
    ind = strmatch('notlabeled', cols, 'exact');
    set(handles.hColor, 'Value', ind);
    lightlist = get(handles.hLight, 'String');
    ind = strmatch('normal', lightlist, 'exact');
    set(handles.hLight, 'Value', ind);
    set(handles.hColDiff, 'Value', 0)
    
    sizes = get(handles.hSize, 'String');
    ind = strmatch('notlabeled', sizes, 'exact');
    set(handles.hSize, 'Value', ind);
    set(handles.hSizeDiff, 'Value', 0)
end;

if dosent
   handles.sel_obj = zeros(size(handles.annotation.bboxes, 1), 1);
   handles = generateSentenceButtons(handles);
end;

if changed == 0
if length(handles.annotation.descriptions)~=length(handles.oldannotation.descriptions)
    changed = 1;
else
   for i = 1 : length(handles.annotation.descriptions)
       if ~strcmp(handles.annotation.descriptions(i).text,handles.oldannotation.descriptions(i).text)
           changed = 1;
       end;
       if changed
           break;
       end;
       if isfield(handles.annotation.descriptions(i), 'obj_id') && isfield(handles.oldannotation.descriptions(i), 'obj_id')
           if length(handles.annotation.descriptions(i).obj_id)~=length(handles.oldannotation.descriptions(i).obj_id)
               changed = 1;
           else
               for j = 1 : length(handles.annotation.descriptions(i).obj_id)
                   obj_id = handles.annotation.descriptions(i).obj_id{j};
                   obj_id_old = handles.oldannotation.descriptions(i).obj_id{j};
                   if isempty(obj_id) & isempty(obj_id_old)
                       continue;
                   end;
                   if ~strcmp(obj_id, obj_id_old)
                       changed = 1;
                   end;
               end;
           end;
       end;
   end;
   if size(handles.annotation.bboxes, 1)~=size(handles.oldannotation.bboxes, 1)
      changed = 1;
   else
       bboxes = handles.annotation.bboxes;
       seg = handles.annotation.seg;
       oldbboxes = handles.oldannotation.bboxes;
       oldseg = handles.oldannotation.seg;       
       for i = 1 : size(bboxes, 1)
           if changed == 1
               continue;
           end;
           if min(min(bboxes == oldbboxes)) == 0
               changed = 1;
           elseif size(seg{i}, 1)~=size(oldseg{i}, 1)
               changed = 1;
           elseif min(min(seg{i} == oldseg{i})) == 0
               changed = 1;
           end;
           if changed == 0
               if ~strcmp(handles.annotation.class, handles.oldannotation.class)
                   changed = 1;
               end;
           end;
       end;
   end;
end;
end;

if changed
   set(handles.hChanges, 'String', 'no');
   set(handles.hChanges, 'BackgroundColor', 1 * [1,0.4,0.4]);
else
    set(handles.hChanges, 'String', 'yes');
    set(handles.hChanges, 'BackgroundColor', 0.929 * [1,1,1]);
end;
guidata(handles.figure1, handles);

function handles = generateSentenceButtons(handles)

if ~isfield(handles, 'hsentences')
    handles.hsentences = [];
end;
handles = settextbuttons(handles);