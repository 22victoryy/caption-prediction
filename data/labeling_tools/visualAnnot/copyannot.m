dataset_globals;
a = 0;

for i = 85 : length(MY_IM_NUM)
    j = MY_IM_NUM(i);
    fileChen = fullfile(DATASET_ROOT, 'tosend', sprintf('%04d.mat', j));
    fileout = fullfile(DATASET_ROOT, 'descriptions_final', sprintf('%04d.mat', j));
    cmd = sprintf('scp %s %s', fileChen, fileout);
    if exist(fileChen, 'file')
        a = a+1;
    end;
    unix(cmd);
end;

fprintf('copied files: %d\n', a);