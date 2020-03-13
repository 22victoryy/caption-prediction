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
%         if allh(i) ~= handles.hClear
            delete(allh(i));
%         end;
    end;
end;

allh = get(handles.hcard,'children');
for ih = 1:numel(allh)
    if allh(ih) ~= handles.hcardupd;
        delete(allh(ih));
    end
end

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
nouns = cell(numel(words),1);
%prepare matrix mapping button to word_id
isent = 1;
iwd = 1;
button_wordid_map = cell(numel(words),1);
for iwords = 1:numel(words)
    if strcmp(words{iwords}, '.') || strcmp(words{iwords},'!');
        isent = isent + 1;
        button_wordid_map{iwords} = [0 0];
        iwd = 1;
        continue;
    end
    button_wordid_map{iwords} = [isent, iwd];
    wordid_button_map(isent,iwd) = iwords;
    iwd = iwd + 1;
end
handles.button_wordid_map = button_wordid_map;
handles.wordid_button_map = wordid_button_map;

if ~isfield(handles.annotation.descriptions(desc_num), 'obj_id')
    handles.annotation.descriptions(desc_num).obj_id = cell(length(words), 1);
end;
if length(handles.annotation.descriptions(desc_num).obj_id) < length(words)
    n = length(handles.annotation.descriptions(desc_num).obj_id);
    handles.annotation.descriptions(desc_num).obj_id = [handles.annotation.descriptions(desc_num).obj_id, cell(1, length(words) - n)]; 
end;
sentence = handles.annotation.descriptions(desc_num).words;
%hsentences = [];
smallletterwidth = 2.8+1 - 0.5;
letterwidth = 6.2+1 - 1;
bigletterwidth = 7.7+1 -1;

texthighlightcol = [1,0.3,0.5; 1,0.8,0.2; 0.3,0.6,1; 0.2,1,0.8; 1,0.2,0.8];
% panel_pos = get(handles.figure1, 'Position');
% panel_w = panel_pos(3) - 1000;
set(handles.hprep, 'Units','pixels');
prep_pos = get(handles.hprep, 'Position');
panel_w = prep_pos(1) - 10;
row = 1;
% height = get(handles.hTextObj, 'Position');
% height = height(3);

       %lineColor = java.awt.Color(1,0,0);  % =red
       %thickness = 1;  % pixels
       %roundedCorners = true;
       %newBorder = javax.swing.border.LineBorder(lineColor,thickness);%,roundedCorners);
       
%for i = 1 : length(sentence)
    hsentences = cell(6, 1);
    for i = 1 : length(hsentences), hsentences{i} = zeros(length(sentence), 1); end;
    numsent= 0 ;
    ind_sent = strmatch('.', sentence);
    numsent = numsent + length(ind_sent);
    ind_sent = strmatch('!', sentence);
    numsent = numsent + length(ind_sent);
    set(handles.hTextObj,'Units','pixels');
    text_pos = get(handles.hTextObj,'position');
    toppos = text_pos(4) - 15;
    lwidth = 3*14 + 28;
    
    %uicontrol('style','text','string','','position',[pos, toppos - (i-1)*15, w, 14],'fontsize',fontsize, 'BackgroundColor', [1,1.,1.], 'FontWeight', 'bold', 'ForegroundColor', [0,0,0], 'HorizontalAlignment', 'left'); 
    pos_cur = pos; breakline = 0;
    for j = 1 : length(sentence)
       word = sentence{j};
       if isfield(handles, 'noun') & length(handles.noun) >= j
           noun{j} = handles.noun{j};
           word = noun{j}.word;
       else
          noun{j}.word = word;
       end;
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
       hpos = toppos - 15 - (row-1) * lwidth;

       cur_text = sentence{j};
       cur_id = button_wordid_map{j};
       if isempty(noun{j})
          noun{j}.id = cur_id;
       end;
       [doedit, cls, adj] = doEditBox(cur_id, handles);
       
%       if doedit
        if 1
            wj = max( num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth,...
            8*letterwidth);
       else
        wj = num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth;
       end
       if pos_cur + wj > panel_w || breakline
           pos_cur = 5;
           row = row+1;
           hpos = hpos - lwidth;
           breakline = 0;
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
       if isfield(handles, 'noun') & length(handles.noun) >= j      
           cls = noun{j}.cls;
       else
           noun{j}.cls = cls;
       end;
       if isfield(handles, 'noun') & length(handles.noun) >= j  
           adj = noun{j}.adj;
           co = noun{j}.co;
       else
          if isempty(adj)
              noun{j}.adj = {};
          else
              noun{j}.adj = {adj};
          end
       
          noun{j}.co = [];
          noun{j}.ischg_adj = 0;
       end;
%       if doedit
           hsentences{2}(j) = uicontrol('Style','pushbutton','string',cls,'Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0], ...
                                    'UserData', j,...
                                    'Callback', {@clscallbackfcn, handles});
           hsentences{3}(j) = uicontrol('Style','pushbutton','string',adj,'Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0], ...
                                    'UserData', j,...
                                    'Callback', {@adjcallbackfcn, handles});
           hsentences{4}(j) = uicontrol('Style','pushbutton','string','','Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0], ...
                                    'UserData', j,...
                                    'Callback', {@cocallbackfcn, handles});
           hsentences{5}(j) = uicontrol('Style','edit','string','','Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0], ...
                                    'UserData', j,...
                                    'Callback', {@sentcallbackfcn, handles});
%        if doedit
           hsentences{6}(j) = uicontrol('Style','pushbutton','string','-','Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0], ...
                                    'UserData', j,...
                                    'Callback', {@addcallbackfcn, handles});
%        else
%            hsentences{6}(j) = uicontrol('Style','pushbutton','string','+','Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                                     'ForegroundColor', [0,0,0], ...
%                                     'UserData', j,...
%                                     'Callback', {@addcallbackfcn, handles});
%        end;
         if ~isempty(noun{j}.co)
             co_txt = [];
             allids = cell2mat(handles.button_wordid_map);
             for kk = 1 : size(noun{j}.co, 1)
                 co_kk = noun{j}.co(kk, :);
                 ind_co = find(allids(:, 1) == co_kk(1) & allids(:, 2) == co_kk(2));
                 if kk > 1
                     comma = ',';
                 else
                     comma = '';
                 end;
                 try
                 co_txt = [co_txt comma sentence{ind_co}(1:2)];
                 end;
             end;
             set(hsentences{4}(j), 'String', co_txt)
         end;
       [outstring,newpos] = textwrap(hsentences{1}(j),{cur_text});
       newpos(3) = max(newpos(3),8*letterwidth);
%       if doedit
           set(hsentences{6}(j), 'position', [newpos(1), hpos-13, letterwidth+1, 14]);
           set(hsentences{2}(j), 'position', [newpos(1)+letterwidth + 1, hpos-13, newpos(3)-letterwidth-1, 14]);
           set(hsentences{3}(j), 'position', [newpos(1), hpos-26, newpos(3), 14]);
           set(hsentences{4}(j), 'position', [newpos(1), hpos-42, newpos(3)-3*letterwidth, 14]);
           set(hsentences{5}(j), 'position', [newpos(1)+newpos(3)-3*letterwidth, hpos-45, 3*letterwidth, 20]);
%        else
%            set(hsentences{2}(j), 'position', [newpos(1), hpos-12, newpos(3), 14]);
%        end;
       set(hsentences{1}(j), 'position', [newpos(1), hpos, newpos(3), 14]);
       noun{j}.isnoun = 1;
       if ~doedit
           noun{j}.isnoun = 0;
           set(hsentences{2}(j), 'visible', 'off');
           set(hsentences{3}(j), 'visible', 'off');
           set(hsentences{4}(j), 'visible', 'off');
           set(hsentences{5}(j), 'visible', 'off');
           set(hsentences{6}(j), 'string', '+');
       end
       %pos_cur = pos_cur + wj + 3;
       pos_cur = newpos(1) + newpos(3) + 3;
       if strcmp(word, '.') || strcmp(word, '!')
           breakline = 1;
       end;
    end;
    handles.hsentences = hsentences;
    handles.noun = noun;
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
                    set(hsentences{i}(j), 'UserData', [hsentences{i}, ind, hsentences{1}, hsentences{2}, hsentences{3}, hsentences{4}, hsentences{5}, hsentences{6}]);
                end;
            end;
        end;
    end;
    
    
    %% obj_cls
    set(handles.hscecls, 'Units','pixels');
    scecls_pos = get(handles.hscecls, 'Position');
    panel_w = scecls_pos(1) - 2;
    set(handles.hobjcls, 'Units','pixels');
    scecls_pos = get(handles.hobjcls, 'Position');
    panel_o = scecls_pos(1) - 2;
    row = 1;
    sentence = handles.obj_cls;
%     sentence = [sentence;'nothing'];
    hsentences = cell(1, 1);
    for i = 1 : length(hsentences), hsentences{i} = zeros(length(sentence)+1, 1); end;
    set(handles.hobjcls,'Units','pixels');
    text_pos = get(handles.hobjcls,'position');
    toppos = text_pos(4) - 25;
    lwidth = 18;
    
    %uicontrol('style','text','string','','position',[pos, toppos - (i-1)*15, w, 14],'fontsize',fontsize, 'BackgroundColor', [1,1.,1.], 'FontWeight', 'bold', 'ForegroundColor', [0,0,0], 'HorizontalAlignment', 'left'); 
    pos_cur = pos; breakline = 0;
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
       hpos = toppos - 15 - (row-1) * lwidth;

       cur_text = sentence{j};
       doedit = 0;
       
       if doedit
            wj = max( num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth,...
            8*letterwidth);
       else
        wj = num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth;
       end
       if panel_o + pos_cur + wj > panel_w || breakline
           pos_cur = 5;
           row = row+1;
           hpos = hpos - lwidth;
           breakline = 0;
       end;
       if 0
       hsentences{1}(j) = uicontrol('Style','text','string',cur_text,'Parent', handles.hobjcls, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.8, ...
                                    'FontWeight', 'bold', 'ForegroundColor', [0,0,0], 'edgecolor', [1,1,1]);%, ...
       else
       hsentences{1}(j) = uicontrol('Style','pushbutton','string',cur_text,'Parent', handles.hobjcls, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.8, ...
                                    'ForegroundColor', [0,0,0],...
                                    'UserData', j,...
                                    'Callback', {@objclscallbackfcn, handles}); 
 
       %jh = findjobj(hsentences{1}(j));
       %jh.Border = newBorder;
       %jh.repaint; 
       end;
                                    %'Callback', []);
                                    %'Callback', @sentcallbackfcn);  
       
       [outstring,newpos] = textwrap(hsentences{1}(j),{cur_text});
       set(hsentences{1}(j), 'position', [newpos(1), hpos, newpos(3), 14]);
       %pos_cur = pos_cur + wj + 3;
       pos_cur = newpos(1) + newpos(3) + 3;
       if strcmp(word, '.') || strcmp(word, '!')
           breakline = 1;
       end;
    end;
    handles.hobjclasses = hsentences;
    for i = 1 : length(hsentences)
        for j = 1 : length(hsentences{i})
            if hsentences{i}(j)
                ind = zeros(size(hsentences{1}, 1), 1);
                ind(j) = 1;
                set(hsentences{i}(j), 'UserData', [hsentences{1}, ind]);
            end;
        end;
    end;

    
    %% sce_cls
    set(handles.hscecls, 'Units','pixels');
    scecls_pos = get(handles.hscecls, 'Position');
    panel_w = scecls_pos(1) + scecls_pos(3) - 2;
    panel_o = scecls_pos(1) - 2;
    row = 1;
    sentence = handles.sce_cls;
    hsentences = cell(1, 1);
    for i = 1 : length(hsentences), hsentences{i} = zeros(length(sentence)+1, 1); end;
    set(handles.hobjcls,'Units','pixels');
    text_pos = get(handles.hobjcls,'position');
    toppos = text_pos(4) - 20;
    lwidth = 18;
    
    %uicontrol('style','text','string','','position',[pos, toppos - (i-1)*15, w, 14],'fontsize',fontsize, 'BackgroundColor', [1,1.,1.], 'FontWeight', 'bold', 'ForegroundColor', [0,0,0], 'HorizontalAlignment', 'left'); 
    pos_cur = pos; breakline = 0;
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
       hpos = toppos - 15 - (row-1) * lwidth;

       cur_text = sentence{j};
       doedit = 0;
       
       if doedit
            wj = max( num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth,...
            8*letterwidth);
       else
        wj = num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth;
       end
       if panel_o + pos_cur + wj > panel_w || breakline
           pos_cur = 5;
           row = row+1;
           hpos = hpos - lwidth;
           breakline = 0;
       end;
       if 0
       hsentences{1}(j) = uicontrol('Style','text','string',cur_text,'Parent', handles.hobjcls, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.8, ...
                                    'FontWeight', 'bold', 'ForegroundColor', [0,0,0], 'edgecolor', [1,1,1]);%, ...
       else
       hsentences{1}(j) = uicontrol('Style','pushbutton','string',cur_text,'Parent', handles.hscecls, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.8, ...
                                    'ForegroundColor', [0,0,0],...
                                    'UserData', j,...
                                    'Callback', {@sceclscallbackfcn, handles}); 
 
       %jh = findjobj(hsentences{1}(j));
       %jh.Border = newBorder;
       %jh.repaint; 
       end;
                                    %'Callback', []);
                                    %'Callback', @sentcallbackfcn);  
       
       [outstring,newpos] = textwrap(hsentences{1}(j),{cur_text});
       set(hsentences{1}(j), 'position', [newpos(1), hpos, newpos(3), 14]);
       %pos_cur = pos_cur + wj + 3;
       pos_cur = newpos(1) + newpos(3) + 3;
       if strcmp(word, '.') || strcmp(word, '!')
           breakline = 1;
       end;
    end;
    handles.hobjclasses = hsentences;
 
    for i = 1 : length(hsentences)
        for j = 1 : length(hsentences{i})
            if hsentences{i}(j)
                ind = zeros(size(hsentences{1}, 1), 1);
                ind(j) = 1;
                set(hsentences{i}(j), 'UserData', [hsentences{1}, ind]);
            end;
        end;
    end;
    
    
    %% preposition area
    
    kc_sentence = handles.annotation.descriptions(desc_num).words;
    allh = get(handles.hprep, 'Children');
    delete(allh);
    set(handles.hprep, 'Units','pixels');
prep_pos = get(handles.hprep, 'Position');
panel_w = prep_pos(1) + prep_pos(3)- 10;
row = 1;
% height = get(handles.hTextObj, 'Position');
% height = height(3);

       %lineColor = java.awt.Color(1,0,0);  % =red
       %thickness = 1;  % pixels
       %roundedCorners = true;
       %newBorder = javax.swing.border.LineBorder(lineColor,thickness);%,roundedCorners);
       
%for i = 1 : length(sentence)
    hsentences = cell(5, 1);
    sentence = handles.annotation.descriptions(desc_num).prep;
    num_prep = 20;
    prep = cell(num_prep,4);
    for i = 1 : length(hsentences), hsentences{i} = zeros(num_prep, 1); end;
%     numsent= 0 ;
%     ind_sent = strmatch('.', sentence);
%     numsent = numsent + length(ind_sent);
%     ind_sent = strmatch('!', sentence);
%     numsent = numsent + length(ind_sent);
    set(handles.hprep,'Units','pixels');
    text_pos = get(handles.hprep,'position');
    toppos =  text_pos(4) - 31;
    lwidth = 16;
    left = 20;
    hpos = toppos - 15;
    ann{1} = uicontrol('Style','text','string','word1','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                        'FontWeight', 'bold','ForegroundColor', [0,0,0],'backgroundcolor',[0.89,0.94,0.9]);
    ann{2} = uicontrol('Style','text','string','preposition','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                        'FontWeight', 'bold','ForegroundColor', [0,0,0],'backgroundcolor',[0.89,0.94,0.9]);
    ann{3} = uicontrol('Style','text','string','word2(opt)','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                        'FontWeight', 'bold','ForegroundColor', [0,0,0],'backgroundcolor',[0.89,0.94,0.9]);
    ann{4} = uicontrol('Style','text','string','word3(opt)','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                        'FontWeight', 'bold','ForegroundColor', [0,0,0],'backgroundcolor',[0.89,0.94,0.9]);
    set(ann{1}, 'position', [left, hpos+16, 60, 14]);
    set(ann{2}, 'position', [left+65, hpos+16, 60, 14]);
   set(ann{3}, 'position', [left+130, hpos+16, 60, 14]);
   set(ann{4}, 'position', [left+195, hpos+16, 60, 14]);
    %uicontrol('style','text','string','','position',[pos, toppos - (i-1)*15, w, 14],'fontsize',fontsize, 'BackgroundColor', [1,1.,1.], 'FontWeight', 'bold', 'ForegroundColor', [0,0,0], 'HorizontalAlignment', 'left'); 
%     pos_cur = pos; breakline = 0;
    for j = 1 : num_prep
%        word = sentence{j};
%        noun{j}.word = word;
%        num = 0; numbig = 0; numsmall = 0;
%        for k = 1 : length(word)
%            if strcmp(lower(word(k)), word(k)) & ~strcmp(word(k), 'w')
%                if strcmp(word(k), 'l') | strcmp(word(k), 'i') | strcmp(word(k), 'j') | strcmp(word(k), 'f') | strcmp(word(k), 't')
%                    numsmall = numsmall + 1;
%                else
%                   num = num+1;
%                end;
%            else
%                numbig = numbig+1;
%            end;
%        end;
       hpos = toppos - 15 - (j-1) * lwidth;

%        cur_text = sentence{j};
%        cur_id = button_wordid_map{j};
%        noun{j}.id = cur_id;
%        [doedit, cls, adj] = doEditBox(cur_id, handles);
       
% %       if doedit
%         if 1
%             wj = max( num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth,...
%             8*letterwidth);
%        else
%         wj = num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth;
%        end
%        if pos_cur + wj > panel_w || breakline
%            pos_cur = 5;
%            row = row+1;
%            hpos = hpos - lwidth;
%            breakline = 0;
%        end;
%        if 0
%        hsentences{1}(j) = uicontrol('Style','text','string',cur_text,'Parent', handles.hTextObj, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.4, ...
%                                     'FontWeight', 'bold', 'ForegroundColor', [0,0,0], 'edgecolor', [1,1,1]);%, ...
%        else
       hsentences{1}(j) = uicontrol('Style','pushbutton','Parent', handles.hprep, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0],...
                                    'UserData', j,...
                                    'Callback', {@prepcallbackfcn, handles}); 
       hsentences{5}(j) = uicontrol('Style','pushbutton','string','+',...
                                    'Parent', handles.hprep, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0],...
                                    'UserData', j,...
                                    'Callback', {@prepaddcallbackfcn, handles});
       %jh = findjobj(hsentences{1}(j));
       %jh.Border = newBorder;
       %jh.repaint; 
%        end;
                                    %'Callback', []);
                                    %'Callback', @sentcallbackfcn);  
%        noun{j}.cls = cls;
%        if isempty(adj)
%            noun{j}.adj = {};
%        else
%            noun{j}.adj = {adj};
%        end
%        noun{j}.co = [];
%        noun{j}.ischg_adj = 0;
%       if doedit
           hsentences{2}(j) = uicontrol('Style','pushbutton','string',' ','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                                    'FontWeight', 'bold','ForegroundColor', [0,0,0], ...
                                    'UserData', j,...
                                    'Callback', {@prepcallbackfcn, handles});
           hsentences{3}(j) = uicontrol('Style','pushbutton','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0], ...
                                    'UserData', j,...
                                    'Callback', {@prepcallbackfcn, handles});
           hsentences{4}(j) = uicontrol('Style','pushbutton','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0], ...
                                    'UserData', j,...
                                    'Callback', {@prepcallbackfcn, handles});
%            hsentences{5}(j) = uicontrol('Style','edit','string','','Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                                     'ForegroundColor', [0,0,0], ...
%                                     'UserData', j,...
%                                     'Callback', {@sentcallbackfcn, handles});
% %        if doedit
%            hsentences{6}(j) = uicontrol('Style','pushbutton','string','-','Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                                     'ForegroundColor', [0,0,0], ...
%                                     'UserData', j,...
%                                     'Callback', {@addcallbackfcn, handles});
%        else
%            hsentences{6}(j) = uicontrol('Style','pushbutton','string','+','Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                                     'ForegroundColor', [0,0,0], ...
%                                     'UserData', j,...
%                                     'Callback', {@addcallbackfcn, handles});
%        end;
%        [outstring,newpos] = textwrap(hsentences{1}(j),{cur_text});
%        newpos(3) = max(newpos(3),8*letterwidth);
%       if doedit
           set(hsentences{1}(j), 'position', [left, hpos, 60, 14]);
           set(hsentences{2}(j), 'position', [left+65, hpos, 60, 14]);
           set(hsentences{3}(j), 'position', [left+130, hpos, 60, 14]);
           set(hsentences{4}(j), 'position', [left+195, hpos, 60, 14]);
           set(hsentences{5}(j), 'position', [left-15, hpos, 10,14]);
%            set(hsentences{5}(j), 'position', [newpos(1)+newpos(3)-3*letterwidth, hpos-45, 3*letterwidth, 20]);
%        else
%            set(hsentences{2}(j), 'position', [newpos(1), hpos-12, newpos(3), 14]);
%        end;
%        set(hsentences{1}(j), 'position', [newpos(1), hpos, newpos(3), 14]);
%        noun{j}.isnoun = 1;


    
       try           
           word = sentence(j,:);
           if isfield(handles, 'prep') & length(handles.prep) >= j
               prep = handles.prep;
               word = prep(j, :);
           else
              prep(j,:) = word;
           end;
           tid = word{1};
           butid = wordid_button_map(tid(1),tid(2));
           word1 = kc_sentence{butid};
           set(hsentences{1}(j),'string',word1);
           
           set(hsentences{2}(j),'string',word{2});
           
           tid = word{3};
           butid = wordid_button_map(tid(1),tid(2));
           word3 = kc_sentence{butid};
           set(hsentences{3}(j),'string',word3);
           if isempty(word{4})
               set(hsentences{4}(j),'visible','off');
           else
               tid = word{4};
               butid = wordid_button_map(tid(1),tid(2));
               word4 = kc_sentence{butid};
               set(hsentences{4}(j),'string',word4);
           end
           set(hsentences{5}(j),'string','-');
       catch
%            noun{j}.isnoun = 0;
           set(hsentences{1}(j), 'visible', 'off');
           set(hsentences{2}(j), 'visible', 'off');
           set(hsentences{3}(j), 'visible', 'off');
           set(hsentences{4}(j), 'visible', 'off');
%            set(hsentences{5}(j), 'string', '+');
       end
       handles.prep = prep;
       %pos_cur = pos_cur + wj + 3;
%        pos_cur = newpos(1) + newpos(3) + 3;
%        if strcmp(word, '.') || strcmp(word, '!')
%            breakline = 1;
%        end;
    end;
     handles.hpreposition = hsentences;
% %     handles.noun = noun;
%     if 0
%         for j = 1 : length(hsentences{1})
%             if hsentences{1}(j)
%                 set(hsentences{1}(j), 'Callback', {@objcallbackfcn, handles});
%             end;
%         end;
%         
%         for j = 1 : length(hsentences{2})
%             if hsentences{2}(j)
%                 set(hsentences{2}(j), 'Callback', {@sentcallbackfcn, handles});
%             end;
%         end;
%     else
        for i = 1 : length(hsentences)
            for j = 1 : length(hsentences{i})
                if hsentences{i}(j)
                    ind = zeros(size(hsentences{1}, 1), 1);
                    ind(j) = 1;
                    idn = zeros(size(hsentences{1}, 1), 1);
                    idn(i) = 1;
                    set(hsentences{i}(j), 'UserData', [hsentences{i}, ind, hsentences{1}, hsentences{2}, hsentences{3}, hsentences{4},hsentences{5}, idn]);
                end;
            end;
        end;
%     end;
    
    
    
 %   handles = plot_sel_obj(handles);
%     guidata(handles.figure1, handles);
%end;

%% verb area
    
    kc_sentence = handles.annotation.descriptions(desc_num).words;
    allh = get(handles.hverb, 'Children');
    delete(allh);
    set(handles.hverb, 'Units','pixels');
prep_pos = get(handles.hverb, 'Position');
panel_w = prep_pos(1) + prep_pos(3)- 10;
row = 1;
% height = get(handles.hTextObj, 'Position');
% height = height(3);

       %lineColor = java.awt.Color(1,0,0);  % =red
       %thickness = 1;  % pixels
       %roundedCorners = true;
       %newBorder = javax.swing.border.LineBorder(lineColor,thickness);%,roundedCorners);
       
%for i = 1 : length(sentence)
    hsentences = cell(2, 1);
    sentence = handles.annotation.descriptions(desc_num).verb;
    num_prep = 14;
     verb = cell(num_prep,1);
    for i = 1 : length(hsentences), hsentences{i} = zeros(num_prep, 1); end;
%     numsent= 0 ;
%     ind_sent = strmatch('.', sentence);
%     numsent = numsent + length(ind_sent);
%     ind_sent = strmatch('!', sentence);
%     numsent = numsent + length(ind_sent);
    set(handles.hverb,'Units','pixels');
    text_pos = get(handles.hverb,'position');
    toppos =  text_pos(4) - 31;
    lwidth = 16;
    left = 30;
%     hpos = toppos - 15;
%     ann{1} = uicontrol('Style','text','string','word1','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                         'FontWeight', 'bold','ForegroundColor', [0,0,0],'backgroundcolor',[0.89,0.94,0.9]);
%     ann{2} = uicontrol('Style','text','string','preposition','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                         'FontWeight', 'bold','ForegroundColor', [0,0,0],'backgroundcolor',[0.89,0.94,0.9]);
%     ann{3} = uicontrol('Style','text','string','word2','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                         'FontWeight', 'bold','ForegroundColor', [0,0,0],'backgroundcolor',[0.89,0.94,0.9]);
%     ann{4} = uicontrol('Style','text','string','word3(opt)','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                         'FontWeight', 'bold','ForegroundColor', [0,0,0],'backgroundcolor',[0.89,0.94,0.9]);
%     set(ann{1}, 'position', [left, hpos+16, 60, 14]);
%     set(ann{2}, 'position', [left+65, hpos+16, 60, 14]);
%    set(ann{3}, 'position', [left+130, hpos+16, 60, 14]);
%    set(ann{4}, 'position', [left+195, hpos+16, 60, 14]);
    %uicontrol('style','text','string','','position',[pos, toppos - (i-1)*15, w, 14],'fontsize',fontsize, 'BackgroundColor', [1,1.,1.], 'FontWeight', 'bold', 'ForegroundColor', [0,0,0], 'HorizontalAlignment', 'left'); 
%     pos_cur = pos; breakline = 0;
    for j = 1 : num_prep
%        word = sentence{j};
%        noun{j}.word = word;
%        num = 0; numbig = 0; numsmall = 0;
%        for k = 1 : length(word)
%            if strcmp(lower(word(k)), word(k)) & ~strcmp(word(k), 'w')
%                if strcmp(word(k), 'l') | strcmp(word(k), 'i') | strcmp(word(k), 'j') | strcmp(word(k), 'f') | strcmp(word(k), 't')
%                    numsmall = numsmall + 1;
%                else
%                   num = num+1;
%                end;
%            else
%                numbig = numbig+1;
%            end;
%        end;
       hpos = toppos - 15 - (j-1) * lwidth;

%        cur_text = sentence{j};
%        cur_id = button_wordid_map{j};
%        noun{j}.id = cur_id;
%        [doedit, cls, adj] = doEditBox(cur_id, handles);
       
% %       if doedit
%         if 1
%             wj = max( num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth,...
%             8*letterwidth);
%        else
%         wj = num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth;
%        end
%        if pos_cur + wj > panel_w || breakline
%            pos_cur = 5;
%            row = row+1;
%            hpos = hpos - lwidth;
%            breakline = 0;
%        end;
%        if 0
%        hsentences{1}(j) = uicontrol('Style','text','string',cur_text,'Parent', handles.hTextObj, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.4, ...
%                                     'FontWeight', 'bold', 'ForegroundColor', [0,0,0], 'edgecolor', [1,1,1]);%, ...
%        else
       hsentences{1}(j) = uicontrol('Style','pushbutton','Parent', handles.hverb, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0],...
                                    'UserData', j,...
                                    'Callback', {@verbcallbackfcn, handles}); 
       hsentences{2}(j) = uicontrol('Style','pushbutton','string','+',...
                                    'Parent', handles.hverb, 'Position',[pos_cur, hpos, wj, 14],'Fontsize',fontsize+0.4, ...
                                    'ForegroundColor', [0,0,0],...
                                    'UserData', j,...
                                    'Callback', {@verbaddcallbackfcn, handles});
       %jh = findjobj(hsentences{1}(j));
       %jh.Border = newBorder;
       %jh.repaint; 
%        end;
                                    %'Callback', []);
                                    %'Callback', @sentcallbackfcn);  
%        noun{j}.cls = cls;
%        if isempty(adj)
%            noun{j}.adj = {};
%        else
%            noun{j}.adj = {adj};
%        end
%        noun{j}.co = [];
%        noun{j}.ischg_adj = 0;
%       if doedit
%            hsentences{2}(j) = uicontrol('Style','pushbutton','string',' ','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                                     'FontWeight', 'bold','ForegroundColor', [0,0,0], ...
%                                     'UserData', j,...
%                                     'Callback', {@prepcallbackfcn, handles});
%            hsentences{3}(j) = uicontrol('Style','pushbutton','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                                     'ForegroundColor', [0,0,0], ...
%                                     'UserData', j,...
%                                     'Callback', {@prepcallbackfcn, handles});
%            hsentences{4}(j) = uicontrol('Style','pushbutton','Parent', handles.hprep, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                                     'ForegroundColor', [0,0,0], ...
%                                     'UserData', j,...
%                                     'Callback', {@prepcallbackfcn, handles});
%            hsentences{5}(j) = uicontrol('Style','edit','string','','Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                                     'ForegroundColor', [0,0,0], ...
%                                     'UserData', j,...
%                                     'Callback', {@sentcallbackfcn, handles});
% %        if doedit
%            hsentences{6}(j) = uicontrol('Style','pushbutton','string','-','Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                                     'ForegroundColor', [0,0,0], ...
%                                     'UserData', j,...
%                                     'Callback', {@addcallbackfcn, handles});
%        else
%            hsentences{6}(j) = uicontrol('Style','pushbutton','string','+','Parent', handles.hTextObj, 'Position',[pos_cur, hpos-18, wj, 25],'Fontsize',fontsize+0.4, ...
%                                     'ForegroundColor', [0,0,0], ...
%                                     'UserData', j,...
%                                     'Callback', {@addcallbackfcn, handles});
%        end;
%        [outstring,newpos] = textwrap(hsentences{1}(j),{cur_text});
%        newpos(3) = max(newpos(3),8*letterwidth);
%       if doedit
           set(hsentences{1}(j), 'position', [left, hpos, 60, 14]);
%            set(hsentences{2}(j), 'position', [left+65, hpos, 60, 14]);
%            set(hsentences{3}(j), 'position', [left+130, hpos, 60, 14]);
%            set(hsentences{4}(j), 'position', [left+195, hpos, 60, 14]);
           set(hsentences{2}(j), 'position', [left-15, hpos, 10,14]);
%            set(hsentences{5}(j), 'position', [newpos(1)+newpos(3)-3*letterwidth, hpos-45, 3*letterwidth, 20]);
%        else
%            set(hsentences{2}(j), 'position', [newpos(1), hpos-12, newpos(3), 14]);
%        end;
%        set(hsentences{1}(j), 'position', [newpos(1), hpos, newpos(3), 14]);
%        noun{j}.isnoun = 1;


    
       try           
           word = sentence{j}.word;
           if isfield(handles, 'verb') & length(handles.verb) >= j
               verb = handles.verb;
               word = verb{j};
           else
               verb{j} = word;
           end;
           set(hsentences{1}(j),'string',word);
           set(hsentences{2}(j),'string','-');
       catch
%            noun{j}.isnoun = 0;
           set(hsentences{1}(j), 'visible', 'off');
%            set(hsentences{2}(j), 'visible', 'off');
%            set(hsentences{5}(j), 'string', '+');
       end
       handles.verb = verb;
       %pos_cur = pos_cur + wj + 3;
%        pos_cur = newpos(1) + newpos(3) + 3;
%        if strcmp(word, '.') || strcmp(word, '!')
%            breakline = 1;
%        end;
    end;
     handles.hverbss = hsentences;
% %     handles.noun = noun;
%     if 0
%         for j = 1 : length(hsentences{1})
%             if hsentences{1}(j)
%                 set(hsentences{1}(j), 'Callback', {@objcallbackfcn, handles});
%             end;
%         end;
%         
%         for j = 1 : length(hsentences{2})
%             if hsentences{2}(j)
%                 set(hsentences{2}(j), 'Callback', {@sentcallbackfcn, handles});
%             end;
%         end;
%     else
        for i = 1 : length(hsentences)
            for j = 1 : length(hsentences{i})
                if hsentences{i}(j)
                    ind = zeros(size(hsentences{1}, 1), 1);
                    ind(j) = 1;
                    idn = zeros(size(hsentences{1}, 1), 1);
                    idn(i) = 1;
                    set(hsentences{i}(j), 'UserData', [hsentences{i}, ind, hsentences{1}, hsentences{2}, idn]);
                end;
            end;
        end;
        
        
        
function [doedit, cls, adj] = doEditBox(word_id, handles)

if word_id(1) == 0 || length(word_id)<2 || word_id(1) > length(handles.annotation.descriptions.tag)
    doedit = 0;
    cls = '';
    adj = '';
    return;
end
description = handles.annotation.descriptions(handles.desc_num);
tag = description.tag{word_id(1)};
try
lexic = tag{word_id(2),2};
catch
   lexic = ''; 
end;
cls = '';
adj = '';
if ~isempty(strfind(lexic,'NN'));
    doedit = 1;
else
    doedit = 0;
end
class_instance_map = handles.annotation.descriptions(handles.desc_num).class_instance_map;
try
id = class_instance_map{word_id(1), word_id(2), 1};
catch
    return;
end
if ~isempty(id)
    cls = description.class(id{1}).name;
    adj_c = description.class(id{1}).instance(id{2}).adj;
    if isempty(adj_c)
        adj = '';
    else
        adj = adj_c{1};
        for iadj = 2: numel(adj_c)
            adj = [adj, ',' adj_c{iadj}];
        end
    end
end


% id = class_instance_map{word_id(1), word_id(2), 1};
% doedit = 1;
% if isempty(id)
%     doedit = 0;
% end


function clscallbackfcn(hObject, EventData, handles)

desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
handles = guidata(handles.hTextObj);
allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
% set(allh(ind, 1), 'String', 'waiting');
% sel_obj = zeros(size(handles.annotation.bboxes, 1), 1);
col = get(handles.hobjcls,'backgroundcolor');
if all(col == [1,1,0])
    set(handles.hobjcls,'backgroundcolor',[0.7,0.78,1]);
    set(handles.hscecls,'backgroundcolor',[0.7,0.78,1]);
    handles.hbutton = [];
    guidata(handles.hTextObj, handles);
    return;
end;

set(handles.hobjcls,'backgroundcolor',[1,1,0]);
set(handles.hscecls,'backgroundcolor',[1,1,0]);
% handles = plotstats(handles, 0);
% handles.sel_obj = sel_obj;
handles.hbutton = {allh(ind,1),'cls', ind};
guidata(handles.hTextObj, handles);


function adjcallbackfcn(hObject, EventData, handles)
desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
handles = guidata(handles.hTextObj);
allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
% set(allh(ind, 1), 'String', 'waiting');
%sel_obj = zeros(size(handles.annotation.bboxes, 1), 1);
col = get(handles.hTextObj,'backgroundcolor');
if all(col == [1,1,0])
    set(handles.hTextObj,'backgroundcolor',[0.87,0.92,0.98]);
    handles.hbutton = [];
    set(allh(ind,1), 'String', '');
    handles.noun{ind}.adj = [];
    guidata(handles.hTextObj, handles);
    return;
end;
set(handles.hTextObj,'backgroundcolor',[1,1,0]);
% handles = plotstats(handles, 0);
%handles.sel_obj = sel_obj;
handles.hbutton = {allh(ind,1),'adj',ind};
guidata(handles.hTextObj, handles);


function cocallbackfcn(hObject, EventData, handles)
desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
handles = guidata(handles.hTextObj);
allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
% set(allh(ind, 1), 'String', 'waiting');
%sel_obj = zeros(size(handles.annotation.bboxes, 1), 1);
col = get(handles.hTextObj,'backgroundcolor');
if all(col == [1,1,0])
    set(handles.hTextObj,'backgroundcolor',[0.87,0.92,0.98]);
    handles.hbutton = [];
    set(allh(ind,1), 'String', '');
    handles.noun{ind}.co = [];
    guidata(handles.hTextObj, handles);
    return;
end;
set(handles.hTextObj,'backgroundcolor',[1,1,0]);
% handles = plotstats(handles, 0);
%handles.sel_obj = sel_obj;
handles.hbutton = {allh(ind,1),'co',ind};
guidata(handles.hTextObj, handles);


function prepcallbackfcn(hObject, EventData, handles)
desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
handles = guidata(handles.hTextObj);
allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
% set(allh(ind, 1), 'String', 'waiting');
%sel_obj = zeros(size(handles.annotation.bboxes, 1), 1);
set(handles.hTextObj,'backgroundcolor',[1,1,0]);
% handles = plotstats(handles, 0);
%handles.sel_obj = sel_obj;
handles.hbutton = {allh(ind,1),'prep',ind};
guidata(handles.hTextObj, handles);


function verbcallbackfcn(hObject, EventData, handles)
desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
handles = guidata(handles.hTextObj);
allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
% set(allh(ind, 1), 'String', 'waiting');
%sel_obj = zeros(size(handles.annotation.bboxes, 1), 1);
set(handles.hTextObj,'backgroundcolor',[1,1,0]);
% handles = plotstats(handles, 0);
%handles.sel_obj = sel_obj;
handles.hbutton = {allh(ind,1),'verb',ind};
guidata(handles.hTextObj, handles);


function addcallbackfcn(hObject, EventData, handles)
desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
handles = guidata(handles.hTextObj);
allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
state = get(allh(ind,8), 'String');
if strcmp(state,'+')
    handles.noun{ind}.isnoun = 1;
    set(allh(ind,4), 'visible', 'on');
    set(allh(ind,5), 'visible', 'on');
    set(allh(ind,6), 'visible', 'on');
    set(allh(ind,7), 'visible', 'on');
    set(allh(ind,8), 'string', '-');
end
if strcmp(state,'-')
    handles.noun{ind}.isnoun = 0;
    set(allh(ind,4), 'visible', 'off');
    set(allh(ind,5), 'visible', 'off');
    set(allh(ind,6), 'visible', 'off');
    set(allh(ind,7), 'visible', 'off');
    set(allh(ind,8), 'string', '+');
end
guidata(handles.hTextObj, handles);

function prepaddcallbackfcn(hObject, EventData, handles)
desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
handles = guidata(handles.hTextObj);
allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
state = get(allh(ind,7), 'String');
if strcmp(state,'+')
%     handles.noun{ind}.isnoun = 1;
    set(allh(ind,3), 'visible', 'on','string','');
    set(allh(ind,4), 'visible', 'on','string','');
    set(allh(ind,5), 'visible', 'on','string','');
    set(allh(ind,6), 'visible', 'on','string','');
    set(allh(ind,7), 'string', '-');
end
if strcmp(state,'-')
    set(allh(ind,3), 'visible', 'off');
    set(allh(ind,4), 'visible', 'off');
    set(allh(ind,5), 'visible', 'off');
    set(allh(ind,6), 'visible', 'off');
    set(allh(ind,7), 'string', '+');
    handles.prep(ind,:) = {[],[],[],[]};
end
guidata(handles.hTextObj, handles);



function verbaddcallbackfcn(hObject, EventData, handles)
desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
handles = guidata(handles.hTextObj);
allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
state = get(allh(ind,4), 'String');
if strcmp(state,'+')
%     handles.noun{ind}.isnoun = 1;
    set(allh(ind,3), 'visible', 'on','string','');
    set(allh(ind,4), 'string', '-');
end
if strcmp(state,'-')
    set(allh(ind,3), 'visible', 'off');
    set(allh(ind,4), 'string', '+');
    handles.verb{ind} = [];
end
guidata(handles.hTextObj, handles);

% function rmvcallbackfcn(hObject, EventData, handles)
% desc_num = handles.desc_num;
% if desc_num == 0 
%     return;
% end;
% handles = guidata(handles.hTextObj);
% allh = get(hObject, 'UserData');
% ind = find(allh(:, 2) == 1);
% cur_obj = ' ';
% fontsize = 10;
% letterwidth = 6.2+1;
% hsentences = handles.hsentences;
% hsentences{2}(ind) = uicontrol('Style','pushbutton','string','+','Parent', handles.hTextObj,'Fontsize',fontsize+0.4, ...
%                                     'ForegroundColor', [0,0,0], ...
%                                     'UserData', ind,...
%                                     'Callback', {@clscallbackfcn, handles});
% hsentences{3}(ind) = 0;
% hsentences{4}(ind) = 0;
% hsentences{5}(ind) = 0;
% hsentences{6}(ind) = 0;
% set(allh(ind,1),'Units','pixel');
% cur_pos = get(allh(ind,3),'Position');
% cur_pos(2) = cur_pos(2)-12;
% set(hsentences{2}(ind), 'position', [cur_pos(1), cur_pos(2), cur_pos(3), 14]);
% hsentences{1}(ind) = allh(ind,3);
% for i = 1 : length(hsentences)
% %    for j = 1 : length(hsentences{i})
%         if hsentences{i}(ind)
%             index = zeros(size(hsentences{1}, 1), 1);
%             index(ind) = 1;
%             set(hsentences{i}(ind), 'UserData', [hsentences{i}, index]);
%         end;
% %    end;
% end;
% handles.hsentences = hsentences;
% guidata(handles.hTextObj, handles);



function sentcallbackfcn(hObject, EventData, handles)
handles = guidata(handles.hTextObj);
desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
strnum = get(allh(ind,1),'String');
num = str2num(strnum);
handles.noun{ind}.co(1,3) = num;
% handles = plotstats(handles, 0);
%handles.sel_obj = sel_obj;
guidata(handles.hTextObj, handles);

function objclscallbackfcn(hObject, EventData, handles)
handles = guidata(handles.hTextObj);
hbutton = handles.hbutton;
if ~strcmp(hbutton{2},'cls')
    return;
end
h = hbutton{1};
set(handles.hobjcls,'backgroundcolor',[0.7,0.78,1]);
set(handles.hscecls,'backgroundcolor',[0.7,0.78,1]);
desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;

allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
cls_name = get(allh(ind,1),'String');
set(h,'String',cls_name);
handles.noun{hbutton{3}}.cls = cls_name;
% handles = plotstats(handles, 0);
%handles.sel_obj = sel_obj;
guidata(handles.hTextObj, handles);



function sceclscallbackfcn(hObject, EventData, handles)
handles = guidata(handles.hTextObj);
hbutton = handles.hbutton;
if ~strcmp(hbutton{2},'cls');
    return;
end
h = hbutton{1};
set(handles.hobjcls,'backgroundcolor',[0.7,0.78,1]);
set(handles.hscecls,'backgroundcolor',[0.7,0.78,1]);
desc_num = handles.desc_num;
if desc_num == 0 
    return;
end;
allh = get(hObject, 'UserData');
ind = find(allh(:, 2) == 1);
cls_name = get(allh(ind,1),'String');
set(h,'String', cls_name);
handles.noun{hbutton{3}}.cls = cls_name;
% handles = plotstats(handles, 0);
%handles.sel_obj = sel_obj;
guidata(handles.hTextObj, handles);



function objcallbackfcn(hObject, EventData, handles)
handles = guidata(handles.hTextObj);
hbutton = handles.hbutton;
if strcmp(hbutton{2},'adj');
    h = hbutton{1};
    set(handles.hTextObj,'backgroundcolor',[0.87,0.92,0.98]);
    desc_num = handles.desc_num;
    if desc_num == 0 
        return;
    end;
    allh = get(hObject, 'UserData');
    ind = find(allh(:, 2) == 1);
    cls_name = get(allh(ind,1),'String');
    if ~handles.noun{hbutton{3}}.ischg_adj
        adj_ph = cls_name;
        handles.noun{hbutton{3}}.ischg_adj = 1;
        handles.noun{hbutton{3}}.adj = {cls_name};
    else
        adj_ph = get(h,'String');        
        if isempty(strfind(adj_ph,','))
            try
            adj_ph = adj_ph(1:3);
            catch
                adj_ph = '';
            end;
        end
        if isempty(adj_ph)
            adj_ph = [cls_name(1:3)];
        else
           adj_ph = [adj_ph, ',' cls_name(1:3)];
        end;
        handles.noun{hbutton{3}}.adj = [handles.noun{hbutton{3}}.adj, cls_name];
    end
    set(h,'String', adj_ph);
%     handles = plotstats(handles, 0);
    %handles.sel_obj = sel_obj;
    guidata(handles.hTextObj, handles);
end
if strcmp(hbutton{2},'co');
    h = hbutton{1};
    set(handles.hTextObj,'backgroundcolor',[0.87,0.92,0.98]);
    desc_num = handles.desc_num;
    if desc_num == 0 
        return;
    end;
    allh = get(hObject, 'UserData');
    ind = find(allh(:, 2) == 1);
    cls_name = get(allh(ind,1),'String');
    cls_id = handles.button_wordid_map{ind};
     co_ph = get(h,'String');  
     if isempty(co_ph)
         co_ph = cls_name(1:2);
     else
    co_ph = [co_ph, ',' cls_name(1:2)];
     end
    set(h,'String', co_ph);
    temp = [cls_id,1];
    handles.noun{hbutton{3}}.co = [handles.noun{hbutton{3}}.co;temp];
%     handles = plotstats(handles, 0);
    %handles.sel_obj = sel_obj;
    guidata(handles.hTextObj, handles);
end
if strcmp(hbutton{2},'prep');
    h = hbutton{1};
    set(handles.hTextObj,'backgroundcolor',[0.87,0.92,0.98]);
    desc_num = handles.desc_num;
    if desc_num == 0 
        return;
    end;
    allh = get(hObject, 'UserData');
    ind = find(allh(:, 2) == 1);
    cls_name = get(allh(ind,1),'String');
    cls_id = handles.button_wordid_map{ind};
    set(h,'String', cls_name);
    allh = get(h, 'UserData');
     temp = [cls_id,1];
    iwo = find(allh(:,8) == 1);
     if iwo == 2
         handles.prep{hbutton{3},iwo} = cls_name;
     else
      handles.prep{hbutton{3},iwo} = temp;
     end
%     handles = plotstats(handles, 0);
    %handles.sel_obj = sel_obj;
    guidata(handles.hTextObj, handles);
end
if strcmp(hbutton{2},'verb');
    h = hbutton{1};
    set(handles.hTextObj,'backgroundcolor',[0.87,0.92,0.98]);
    desc_num = handles.desc_num;
    if desc_num == 0 
        return;
    end;
    allh = get(hObject, 'UserData');
    ind = find(allh(:, 2) == 1);
    cls_name = get(allh(ind,1),'String');
    cls_id = handles.button_wordid_map{ind};
    set(h,'String', cls_name);
      handles.verb{hbutton{3}} = cls_name;
%     handles = plotstats(handles, 0);
    %handles.sel_obj = sel_obj;
    guidata(handles.hTextObj, handles);
end


function [obj_num, ids] = selectObjects(handles)

obj_num = [];
ids = [];


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
        
% if isempty(handles.hsentences) || isempty(handles.hsentences{1}) || handles.hsentences{1}(1) == 0
%     return;
% end;
%     allh = get(handles.hsentences{1}(1), 'UserData');
%     sel_obj = zeros(size(handles.annotation.bboxes, 1), 1);
%     for i = 1 : size(allh, 1)
%         if allh(i, 2) > 0
%            ids_string = get(allh(i, 2), 'String');
%            ids = str2num(ids_string);
%            ind = find(ids > 0 & ids <= size(handles.annotation.bboxes, 1));
%            ids = ids(ind);
%            sel_obj(ids) = 1;
%         end;
%     end;
%     handles.sel_obj = sel_obj;
return;