ROOT = fullfile(pwd, '..', '..');
DATASET_ROOT = fullfile(ROOT,'data');
SENT_DIR = fullfile(DATASET_ROOT, 'descriptions');
%SENT_USER = fullfile(DATASET_ROOT, 'descriptions_%s');
SENT_USER = fullfile(DATASET_ROOT, 'descriptions');
IMAGE_DIR = fullfile(DATASET_ROOT, 'images');
DEPTH_DIR = fullfile(DATASET_ROOT, 'depths');  % doesn't need to exist
if ~exist(SENT_DIR, 'dir')
    mkdir(SENT_DIR);
end;
MY_IM_NUM = [1:1449];
%datasplit = load(fullfile(DATASET_ROOT, 'split.mat'));
%MY_IM_NUM = datasplit.train;