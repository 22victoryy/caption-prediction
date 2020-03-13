function obj_num = selectObj(x, y, handles)

bboxes = handles.annotation.bboxes;
seg = handles.annotation.seg;
isin = zeros(size(bboxes, 1), 2);
obj_num = 0;
for i = 1 : size(bboxes, 1)
    if x >= bboxes(i, 1) && x<= bboxes(i,1) + bboxes(i, 3) && y >= bboxes(i, 2) && y <= bboxes(i, 2) + bboxes(i, 4)
        if ~isempty(seg{i})
            in = inpoly([x,y],seg{i});
            isin(i, 1) = in;
        else
           isin(i, 1) = 1;
        end;
        center = bboxes(i, 1:2) + 0.5 * bboxes(i, 3:4);
        isin(i, 2) = norm(center - [x,y]);
    end;
end;
if ~isempty(bboxes)
   ind = find(isin(:, 1));
   if ~isempty(ind)
       [m, m_ind] = min(isin(ind, 2));
       ind = ind(m_ind);
       obj_num = ind;
   end;
end;