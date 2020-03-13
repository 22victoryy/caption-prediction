function handles = settextbuttons(handles)

fontsize = 10;
toppos = 102;
pos = 5;
w = 560;
allh = get(handles.hTextObj, 'Children');
hsentences = handles.hsentences;
if 0
for i = 1 : length(hsentences)
    for j = 1 : length(hsentences{i})
       if hsentences{i}(j) > 0
          try
             delete(hsentences{i}(j));
          catch
              hout = getButtonHandle(allh, hsentences{i}(j));
              delete(hout);
          end;
       end;
    end;
end;
else
    for i = 1 : length(allh)
        if allh(i) ~= handles.hClear
            delete(allh(i));
        end;
    end;
end;
desc_num = handles.desc_num;
annotation = handles.annotation;
if desc_num == 0 || desc_num > length(annotation.descriptions)
    return;
end;
if isempty(handles.annotation.descriptions(desc_num).text)
    return;
end;

words = splitSentence(handles.annotation.descriptions(desc_num).text);
handles.annotation.descriptions(desc_num).words = words;

if ~isfield(handles.annotation.descriptions(desc_num), 'obj_id')
    handles.annotation.descriptions(desc_num).obj_id = cell(length(words), 1);
end;
if length(handles.annotation.descriptions(desc_num).obj_id) < length(words)
    n = length(handles.annotation.descriptions(desc_num).obj_id);
    handles.annotation.descriptions(desc_num).obj_id = [handles.annotation.descriptions(desc_num).obj_id; cell(length(words) - n, 1)]; 
end;
sentence = handles.annotation.descriptions(desc_num).words;
%hsentences = [];
smallletterwidth = 2.8+1;
letterwidth = 6.2+1;
bigletterwidth = 7.7+1;
if ~isempty(sentence)
    showmentioned = get(handles.hShowMentioned, 'Value');
    if showmentioned
       %handles.obj_num = 0;
       set(handles.hShowSeg, 'Value', 1);
       %set(handles.hShowAll, 'Value', 1);

       handles = plotstats(handles, 0);
       guidata(handles.figure1, handles);
       annotate_objects_plots(handles)
    end;
end;

texthighlightcol = [1,0.3,0.5; 1,0.8,0.2; 0.3,0.6,1; 0.2,1,0.8; 1,0.2,0.8];
panel_pos = get(handles.figure1, 'Position');
panel_w = panel_pos(3) - 25;
row = 1;

       %lineColor = java.awt.Color(1,0,0);  % =red
       %thickness = 1;  % pixels
       %roundedCorners = true;
       %newBorder = javax.swing.border.LineBorder(lineColor,thickness);%,roundedCorners);
       
%for i = 1 : length(sentence)
    hsentences = cell(2, 1);
    for i = 1 : length(hsentences), hsentences{i} = zeros(length(sentence), 1); end;
    %uicontrol('style','text','string','','position',[pos, toppos - (i-1)*15, w, 14],'fontsize',fontsize, 'BackgroundColor', [1,1.,1.], 'FontWeight', 'bold', 'ForegroundColor', [0,0,0], 'HorizontalAlignment', 'left'); 
    pos_cur = pos;
    for j = 1 : length(sentence)
       word = sentence{j};
       num = 0; numbig = 0; numsmall = 0;
       for k = 1 : length(word)
           if strcmp(lower(word(k)), word(k)) & ~strcmp(word(k), 'w')
               if strcmp(word(k), 'l') | strcmp(word(k), 'i') | strcmp(word(k), 'j') | strcmp(word(k), 'f') | strcmp(word(k), 't')
                   numsmall = numsmall + 1;
               else
                  num = num+1;
               end;
           else
               numbig = numbig+1;
           end;
       end;
       hpos = toppos - 15 - (row-1) * 34;

       cur_text = sentence{j};
       wj = num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth;
       if pos_cur + wj > panel_w
           pos_cur = 5;
           row = row+1;
           hpos = hpos - 34;
       end;
       if 0
       hsentences{1}(j) = uicontrol('Style','text','string',cur_text,'Parent', handles.hTextObj, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.4, ...
                                    'FontWeight', 'bold', 'ForegroundColor', [0,0,0], 'edgecolor', [1,1,1]);%, ...
       else
       hsentences{1}(j) = uicontrol('Style','pushbutton','string',cur_text,'Parent', handles.hTextObj, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.4, ...
                                    'FontWeight', 'bold', 'ForegroundColor', [0,0,0],...
                                    'UserData', j,...
                                    'Callback', {@objcallbackfcn, handles}); 
 
       %jh = findjobj(hsentences{1}(j));
       %jh.Border = newBorder;
       %jh.repaint; 
       end;
                                    %'Callback', []);
                                    %'Callback', @sentcallbackfcn);  
       doedit = doEditBox(cur_text);
       if doedit
           cur_obj = handles.annotation.descriptions(desc_num).obj_id{j};
                  hsentences{2}(j) = uicontrol('Style','edit','string',cur_obj,'Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0], ...
                                    'UserData', j,...
                                    'Callback', {@sentcallbackfcn, handles});
       end;
       [outstring,newpos] = textwrap(hsentences{1}(j),{cur_text});
       set(hsentences{1}(j), 'position', [newpos(1), hpos, newpos(3), 14]);
       if doedit
           set(hsentences{2}(j), 'position', [newpos(1), hpos-18, newpos(3)+5, 20]);
       end;
       %pos_cur = pos_cur + wj + 3;
       pos_cur = newpos(1) + newpos(3) + 3;
    end;
    handles.hsentences = hsentences;
    if 0
        for j = 1 : length(hsentences{1})
            if hsentences{1}(j)
                set(hsentences{1}(j), 'Callback', {@objcallbackfcn, handles});
            end;
        end;
        
        for j = 1 : length(hsentences{2})
            if hsentences{2}(j)
                set(hsentences{2}(j), 'Callback', {@sentcallbackfcn, handles});
            end;
        end;
    else
        for i = 1 : length(hsentences)
            for j = 1 : length(hsentences{i})
                if hsentences{i}(j)
                    ind = zeros(size(hsentences{1}, 1), 1);
                    ind(j) = 1;
                    set(hsentences{i}(j), 'UserData', [hsentences{1}, hsentences{2}, ind]);
                end;
            end;
        end;
    end;
    
    handles = plot_sel_obj(handles);
    guidata(handles.figure1, handles);
%end;


function doedit = doEditBox(word)

noedit = {'and', 'is', 'the', 'then', 'in', 'out', 'next', 'front', 'distance',...
    'behind', 'below', 'fast', 'slow', 'above', 'on', 'up', 'down', 'inside', 'be',...
    'will', 'left', 'right', 'go', 'went', 'going', 'driving', 'riding', 'speeding', 'speed',...
    'was', 'were', 'you', 'safe', 'there', 'far', 'here', 'near', 'coming', 'through'};

doedit = 1;
if length(word) <= 2 && ~strcmp(lower(word), 'tv')
    doedit = 0;
    return;
end;
for i = 1 : length(noedit)
    if strmatch(word, noedit{i})
        doedit = 0;
    end;
end;

%function sentcallbackfcn(hObject, EventData, handles)
function sentcallbackfcn(hObject, EventData, handles)

ids_string = get(hObject, 'String');
try
    ids = str2num(ids_string);
    desc_num = handles.desc_num;
    if desc_num == 0 
        return;
    end;
    %ind = find(abs(handles.hsentences{2} - hObject) < 0.1);
    %if length(ind) > 1
    %    [ind, ~] = min(ind);
    %end;
    allh = get(hObject, 'UserData');
    ind = find(allh(:, 3) == 1);
    handles.annotation.descriptions(desc_num).obj_id{ind} = ids_string;
    sel_obj = zeros(size(handles.annotation.bboxes, 1), 1);
    for i = 1 : size(allh, 1)
        if allh(i, 2) > 0
           ids_string = get(allh(i, 2), 'String');
           handles.annotation.descriptions(desc_num).obj_id{i} = ids_string;
           ids = str2num(ids_string);
           ind = find(ids > 0 & ids <= size(handles.annotation.bboxes, 1));
           ids = ids(ind);
           sel_obj(ids) = 1;
        end;
    end;
    handles.sel_obj = sel_obj;
    annotate_objects_plots(handles)
    handles = plotstats(handles, 0);
    guidata(hObject, handles);
catch
    set(hObject, 'String', '');
    fprintf('should be convertible to numbers\n');
end;

function objcallbackfcn(hObject, EventData, handles)

desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
[~, ids] = selectObjects(handles);

ids_string = [];
for i = 1 : length(ids)
    if i > 1
       ids_string = sprintf('%s,%d', ids_string, ids(i));
    else
       ids_string = sprintf('%d', ids(i));
    end;
end;
%ind = find(abs(handles.hsentences{2} - hObject) < 0.1);
%if length(ind) > 1
%    [ind, ~] = min(ind);
%end;
allh = get(hObject, 'UserData');
ind = find(allh(:, 3) == 1);
set(allh(ind, 2), 'String', ids_string);
sel_obj = zeros(size(handles.annotation.bboxes, 1), 1);

for i = 1 : size(allh, 1)
    if allh(i, 2) > 0
       ids_string = get(allh(i, 2), 'String');
       handles.annotation.descriptions(desc_num).obj_id{i} = ids_string;
       ids = str2num(ids_string);
       ind = find(ids > 0 & ids <= size(handles.annotation.bboxes, 1));
       ids = ids(ind);
       sel_obj(ids) = 1;
    end;
end;
%handles.annotation.descriptions(desc_num).obj_id{ind} = ids_string;
handles = plotstats(handles, 0);
handles.sel_obj = sel_obj;
annotate_objects_plots(handles)
guidata(hObject, handles);



function [obj_num, ids] = selectObjects(handles)

set(handles.hShowMentioned, 'Value', 1);
axes(handles.axes2);
[x,y] = ginput();
obj_num = [];
for i = 1 : length(x)
    obj_num_i = selectObj(x(i), y(i), handles);
    obj_num = [obj_num; obj_num_i];
end;
obj_num = unique(obj_num);
obj_num = obj_num(obj_num > 0);
ids = zeros(length(obj_num), 1);
for i = 1 : length(obj_num)
    ids(i) = obj_num(i);
end;


function val = getFrameNum(handles)

val = round(get(handles.Frameslider, 'Value'));
if val < 1, val = 1; end;
if val > get(handles.Frameslider, 'Max')
    val = get(handles.Frameslider, 'Max');
end;


function hout = getButtonHandle(allh, h)

              d = abs(allh - h);
              ind = find(d < 0.1);
              if length(ind) > 1
                 [m, m_ind] = min(d(ind));
                 ind = ind(m_ind);
              end;
              hout = allh(ind);
              
              
function handles = plot_sel_obj(handles)
        
if isempty(handles.hsentences) || isempty(handles.hsentences{1}) || handles.hsentences{1}(1) == 0
    return;
end;
    allh = get(handles.hsentences{1}(1), 'UserData');
    sel_obj = zeros(size(handles.annotation.bboxes, 1), 1);
    for i = 1 : size(allh, 1)
        if allh(i, 2) > 0
           ids_string = get(allh(i, 2), 'String');
           ids = str2num(ids_string);
           ind = find(ids > 0 & ids <= size(handles.annotation.bboxes, 1));
           ids = ids(ind);
           sel_obj(ids) = 1;
        end;
    end;
    handles.sel_obj = sel_obj;
    annotate_objects_plots(handles)