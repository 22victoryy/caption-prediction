function viz_mentioned(n_scenes)

dataset_globals;
user_dir = sprintf(SENT_USER, 'info');
outdir = fullfile(user_dir, 'viz_mentioned');
info_dir = sprintf(SENT_USER, 'info');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end;
map = colormap('jet');
map = map([size(map, 1):-1:1]', :);

for i = 1 : n_scenes
    im_name = MY_IM_NUM(i);
    imdata = load(fullfile(LABEL_DIR, sprintf('sc%04d.mat', im_name)));
    try
       annotation = load(fullfile(user_dir, sprintf('in%04d.mat', im_name)));
    catch
       annotdata = load(fullfile(user_dir, sprintf('%04d.mat', im_name))); 
       annotation = annotdata.annotation;
    end;
    outfile = fullfile(outdir, sprintf('%04d.jpg', im_name));
    close all;
    annotate_objects_plots(imdata.image, annotation, map)
    export_fig(outfile)
end;



function annotate_objects_plots(im, annotation, map)

figure('position', [100, 100, size(im, 2), size(im, 1)]);
subplot('position', [0,0,1,1]);
imshow(im)
n_sent = 5;

descriptions = annotation.descriptions(1);
if isfield(annotation, 'seg')
    obj_id = [];
    for i = 1 : length(descriptions.obj_id)
        obj_id_i = [];
        try
           obj_id_i = str2num(descriptions.obj_id{i});
           if size(obj_id_i, 2) > size(obj_id_i, 1)
               obj_id_i = obj_id_i';
           end;
        end;
       obj_id = [obj_id; obj_id_i];
    end;
    if ~isempty(obj_id)
       obj_id = unique(obj_id);
    end;
    
   nouns = descriptions.noun_all;
   obj_ids = [];
   j_sents = [];
   for j = 1 : length(nouns)
      noun = nouns(j);
      try
      obj_id = descriptions.obj_id{descriptions.sent_word(noun.id(1), noun.id(2))};
      catch
          fprintf('error');
          continue;
      end;
      if isempty(obj_id)
          continue;
      end;
      j_sent = noun.id(1);
      obj_id = str2num(obj_id);
      obj_ids = [obj_ids; obj_id'];
      j_sents = [j_sents; j_sent * ones(length(obj_id), 1)];
   end;
   [obj_ids_un,v] = unique(obj_ids);
   %j_sents = j_sents(v);
   j_sents(j_sents > n_sent) = n_sent;
    
    for i = 1 : length(obj_ids_un)
        obj = obj_ids_un(i);
        ind_obj = find(obj_ids == obj);
        j = min(j_sents(ind_obj));
        if obj < 1 || obj > length(annotation.seg)
            continue;
        end;
        %try
        %col = [1,0,0.5];
        %col_face = [1, 0, 1];
        col = map(round((j-1)* (size(map, 1) - 1) /(n_sent-1))+1, :);
        col_face = 0.7*col + 0.3*[1,0,0];
        seg = annotation.seg{obj};
        patch(seg(:, 1),seg(:, 2), ones(size(seg, 1), 1),'facecolor', col_face,'facealpha', 0.2, 'EdgeColor',col,'linewidth', 2.5);
    end;
end;
