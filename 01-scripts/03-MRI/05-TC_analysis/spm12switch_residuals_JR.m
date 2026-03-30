

[spmpath name]=fileparts(which('spm'));
if ~isempty(spmpath)
    %% make a clean removing of old spm-path
    allDir=genpath(spmpath);
    tmp=regexp(allDir,':','split');
    x = path; % string
    y=textscan(x,'%s','delimiter',pathsep); % cell array
    for ix=1:length(tmp)
        if sum(strcmp(y{1},tmp{ix}))>0
            rmpath(tmp{ix})
        end
    end
end

newpath='/home/jonathan.reinwald/Programs/spm12_residualsnotdeleted';
addpath(genpath(newpath))
fprintf('added path: %s\n',newpath);

clear spmpath newpath name tmp allDir ix x y