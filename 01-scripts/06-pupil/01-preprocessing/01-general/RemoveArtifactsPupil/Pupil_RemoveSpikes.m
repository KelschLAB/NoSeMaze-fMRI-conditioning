%%
clear
PVdirectory = "/home/walter.canedoriedel/Desktop/Matrices";
addpath(genpath(PVdirectory))
Functions_directory = "/home/walter.canedoriedel/Desktop/GLM_pipeline/"; addpath(genpath(Functions_directory))
cd(Functions_directory)
load("initWorkspace.mat"); clear Regions

parfor id = 1:25
    fig = figure;
    fig.Units = "Centimeters";
    fig.Position = [10, 10, 27, 20];
    
    Loaded = parload("pupilMatrices_NW_" + num2str(id) + ".mat"); Matrices = Loaded.Matrices;
    F = fields(Matrices);
    for f = 1:numel(F)
        for s = 1:size(Matrices.(F{f}).matrix, 1)
            num2str(id) + " " + F{f}
            if id == 15 && f == 6
                [Matrices.(F{f}).matrix(1, :, :), ~] = RemovePikes_NaN_35(Matrices.(F{f}).matrix(1, :, :), Matrices.(F{f}).trialMatrix(1, :, :), Events, 4, 1);
            else
                [Matrices.(F{f}).matrix(1, :, :), ~] = RemovePikes_NaN(Matrices.(F{f}).matrix(1, :, :), Matrices.(F{f}).trialMatrix(1, :, :), Events, 4, 1);
            end
            sgtitle("Mouse " + F{f} + " session count: " + num2str(id - 2 + s))
            parsave_img("/home/walter.canedoriedel/Desktop/GLM_pipeline/CorrectPupil", "CorrectedPupil_" + num2str(id-2+s) + "_" + F{f}, 0, 1, 0)
        end
    end
    parsave("/home/walter.canedoriedel/Desktop/Matrices/Pupil/" + "pupilMatrices_NW_NoPikes_" + num2str(id), Matrices);
end