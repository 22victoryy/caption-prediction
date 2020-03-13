function annotate_objects_plots(handles)

showim = get(handles.hImage, 'Value');
if 1%plot_im
   % figure(1);
   axes(handles.axes2);
   cla;
   im = handles.M.image;
   depth = [];
   if isfield(handles.M, 'depths') && ~showim
       depth = handles.M.depths;
   end;
   if isempty(depth)
      imshow(im)
   else
       imagesc(depth)
       axis equal;
       axis off;
   end;
   %axis equal;
   %whitebg('k');
   %set(gca, 'XlimMode', 'auto');
   %set(gca, 'YlimMode', 'auto');
   if isfield(handles, 'xlim')
      xlim(handles.xlim);
      ylim(handles.ylim);
   end;
end;

show2dbox = 0;
showmentioned = get(handles.hShowMentioned, 'Value');
showsegobj = get(handles.hShowSeg, 'Value');
showall = get(handles.hShowAll, 'Value');

axes(handles.axes2);
annotation = handles.annotation;
obj_num = handles.obj_num;

if showsegobj && isfield(annotation, 'seg')
    alpha = 0.25;
    obj_to_plot = obj_num;
    sel_obj = zeros(size(annotation.bboxes, 1), 1);
    if isfield(handles, 'sel_obj') && showmentioned
        sel_obj = handles.sel_obj;
    end;
    if showall, obj_to_plot = [1:length(annotation.seg)]';
    elseif showmentioned
        ind_sel = find(sel_obj);
        obj_to_plot = ind_sel;
    end;
    for i = 1 : length(obj_to_plot)
        obj = obj_to_plot(i);
        if obj < 1 || obj > length(annotation.seg)
            continue;
        end;
        %try
            seg = annotation.seg{obj};
            if size(seg, 1) < 1
                continue;
            end;
            if obj == obj_num || sel_obj(obj) > 0
                col = [1,0,0.5];
            else
                col = [1,0.6,0];
            end;
            if obj == obj_num
                col = [0,0.2,1];
            end;
           % patch(seg(:, 1),seg(:, 2), col, 'Parent', handles.axes2, 'EdgeColor','k','linewidth', 2.,'FaceAlpha', alpha,'AmbientStrength', 0, 'FaceLighting', 'flat', 'BackFaceLighting', 'lit');
        %end;
        %patch(seg(:, 1),seg(:, 2), ones(size(seg, 1), 1), 'facecolor', col, 'EdgeColor','k','linewidth', 2.5,'FaceAlpha', alpha,'AmbientStrength', 0, 'FaceLighting', 'flat', 'BackFaceLighting', 'lit');
        patch(seg(:, 1),seg(:, 2), ones(size(seg, 1), 1),'facecolor', 'none','EdgeColor',col,'linewidth', 2.5);
        if ~show2dbox
            d = dist2(seg, [0,0]);
            [m, m_ind] = min(d);
            p = seg(m_ind, :);
            id = sprintf('%d', obj);
            text(p(1)+7, p(2)+8, id, 'BackgroundColor',[1,0.5,0.5],'Fontsize',9,'fontweight','bold','Color',[0,0,0]);
        end;
    end;
    if numel(find(obj_to_plot==obj_num))
        seg = annotation.seg{obj_num};
        col = [0,0.0,1];
        try
        patch(seg(:, 1),seg(:, 2), ones(size(seg, 1), 1),'facecolor', 'none','EdgeColor',col,'linewidth', 3);
        end;
    end;
end;

if show2dbox       
   hold on;
   lw = 2.5;
   if showall, vizbox = ones(size(annotation.bboxes, 1), 1); 
   else vizbox = zeros(size(annotation.bboxes, 1), 1); if obj_num > 0, vizbox(obj_num) = 1; end; end;
   for i = 1 : size(annotation.bboxes, 1)
       if vizbox(i)
       box2d = annotation.bboxes(i, :);
       cls = annotation.class{i};
       if ~numel(cls), cls = ''; end;
       id = i;
       cls = sprintf('%s (%d)', cls, id);
       if numel(box2d) && ~all(box2d == 0)
          if i==obj_num
              rectangle('position', box2d, 'edgecolor',[1,0,0],'linestyle','-','linewidth',lw);
              text(box2d(1, 1)+4, box2d(1, 2)+5, cls, 'BackgroundColor',[1,0.5,0.5],'Fontsize',9,'fontweight','bold','Color',[0,0,0]);
          else
              rectangle('position', box2d, 'edgecolor',[1,1,0],'linestyle','-','linewidth',lw);
              text(box2d(1, 1)+4, box2d(1, 2)+5, cls, 'BackgroundColor',[1,1,0.3],'Fontsize',9,'fontweight','bold','Color',[0,0,0]);
          end;
        end;
       end;
   end;
   hold off;
end;
