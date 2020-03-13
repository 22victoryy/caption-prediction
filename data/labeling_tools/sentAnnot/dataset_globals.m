ROOT = fullfile(pwd, '..', '..');
DATASET_ROOT = fullfile(ROOT,'data');
%LABEL_DIR = fullfile(DATASET_ROOT, 'scenes');
SENT_DIR = fullfile(DATASET_ROOT, 'descriptions');
SENT_USER = fullfile(DATASET_ROOT, 'descriptions_%s');
if ~exist(SENT_DIR, 'dir')
    mkdir(SENT_DIR);
end;
%MY_IM_NUM = [1:1449];
imfile = fullfile(DATASET_ROOT, 'myimages.mat');
if exist([imfile], 'file')
   data = load(imfile);
   MY_IM_NUM = data.MY_IM_NUM;
else
    files = dir(fullfile(sprintf(SENT_USER, 'info'), 'in*.mat'));
    MY_IM_NUM = zeros(length(files), 1);
    for i = 1 : length(files)
        [~,name] = fileparts(files(i).name);
        name = name(3:end);
        MY_IM_NUM(i) = str2num(name);
    end;
    save(imfile, 'MY_IM_NUM')
end;
history_file = fullfile(DATASET_ROOT, 'history.mat');