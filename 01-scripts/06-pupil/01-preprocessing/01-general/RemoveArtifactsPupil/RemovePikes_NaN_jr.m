function [M, Removed] = RemovePikes_NaN_jr(M, TM, std_thresh, Thresh, IfPlot, abs_thresh)
% modified by JR 07/2022
Copy = M;
Mask = ones(size(M)); Mask(isnan(M)) = NaN;
Plo = NaN(size(M));
delta = M(1, 2:end, :) - M(1, 1:end-1, :);
% The "setdiff" is because I have a jitter bin
    %STD = std(delta, 0, "all", "omitnan"); AVG = mean(delta, "all", "omitnan");
STD = std(delta, 0, "all", "omitnan"); AVG = mean(delta, "all", "omitnan");
OL = zeros(size(delta));
if isnan(abs_thresh)
    OL(delta<AVG-std_thresh*STD) = -1; OL(delta>AVG+std_thresh*STD) = 2;
elseif ~isnan(abs_thresh)
    OL(delta<-abs_thresh) = -1; OL(delta>abs_thresh) = 2;
end
% OL(delta<-3std_thresh) = -1; OL(delta>+3std_thresh) = 2; 
% OL(1, Events(3)-1, :) = 0;
Removed = 0; 
for tr = 1:size(OL,3)
    win = 0; cou = 0;
    ver = 0; nichte = 0;
    for b = 1:size(OL,2)
        if cou == Thresh
            win = 0; cou = 0;
            ver = 0; nichte = 0;
            continue
        end
        if OL(1, b, tr) == 0
            if win ~= 0
                cou = cou+1;
                continue
            end
        elseif OL(1, b, tr) == 2
            if win == 0
                ver = b+1;
                win = 2;
            elseif win == -1
                nichte = b;
                win = 1;
            elseif win == 2
                cou = 0;
            end
        elseif OL(1, b, tr) == -1
            if win == 0
                ver = b+1;
                win = -1;
            elseif win == 2
                nichte = b;
                win = 1;
            elseif win == -1
                cou = 0;
            end
        end
        if win == 1
            Mask(1, ver:nichte, tr) = NaN;
            Plo(1, ver-1:nichte+1, tr) = M(1, ver-1:nichte+1, tr);
            OL(1, ver-1:nichte-1, tr) = 0;
            Removed = Removed + 1;
            win = 0; cou = 0;
            ver = 0; nichte = 0;
        end
    end
end
Copy = Copy.*Mask;
delta = Copy(1, 2:end, :) - Copy(1, 1:end-1, :);
OL = zeros(size(delta));
OL(delta<AVG-std_thresh*STD) = -1; OL(delta>AVG+std_thresh*STD) = -1; 
% OL(delta<-3std_thresh) = -1; OL(delta>3std_thresh) = -1; 
% OL(1, Events(3)-1, :) = 0;
OL(isnan(delta)) = 2;
for tr = 1:size(OL,3)
    win = 0; cou = 0;
    ver = 0; nichte = 0;
    for b = 1:size(OL,2)
        if cou == Thresh
            win = 0; cou = 0;
            ver = 0; nichte = 0;
            continue
        end
        if OL(1, b, tr) == 0
            if win ~= 0
                cou = cou+1;
                continue
            end
        elseif OL(1, b, tr) == 2
            if win == 0
                ver = b+1;
                win = 2;
            elseif win == -1
                nichte = b;
                win = 1;
            elseif win == 2
                cou = 0;
            end
        elseif OL(1, b, tr) == -1
            if win == 0
                ver = b+1;
                win = -1;
            elseif win == 2
                nichte = b;
                win = 1;
            elseif win == -1
                cou = 0;
            end
        end
        if win == 1
            Mask(1, ver:nichte, tr) = NaN;
            Plo(1, ver-1:nichte+1, tr) = M(1, ver-1:nichte+1, tr);
            OL(1, ver-1:nichte-1, tr) = 0;
            Removed = Removed + 1;
            win = 0; cou = 0;
            ver = 0; nichte = 0;
        end
    end
end
Copy = M.*Mask;
Pla = NaN(size(M));
Interpolated = 0;
for tr = 1:size(OL,3)
    Times = 0;
    [Copy(1, :, tr), Pla(1, :, tr), Times] = InterpolateNaN_jr(Copy(1, :, tr), Thresh+1);
    Interpolated = Interpolated + Times;
end
if IfPlot
    clf
    tiledlayout(2, 2)
    nexttile
        plot(squeeze(M));
        hold on
        plot(squeeze(Plo), "-r", "LineWidth", 2)
        title(["Original data"; "Trials"])
%         xline([Events(1), Events(4), Events(6)], "k", "LineWidth", 2, "Alpha", 1)
%         xline([Events(2), Events(std_thresh)], "--k", "LineWidth", 2, "Alpha", 1)
    nexttile
        plot(squeeze(M.*Mask));
        hold on
        plot(squeeze(Pla), "-r", "LineWidth", 2)
        title(["Corrected data, " + num2str(Removed) + " spikes removed"; " and " + num2str(Interpolated) + " interpolations where NaN (max std_thresh in row)"])
%         xline([Events(1), Events(4), Events(6)], "k", "LineWidth", 2, "Alpha", 1)
%         xline([Events(2), Events(std_thresh)], "--k", "LineWidth", 2, "Alpha", 1)    
%     nexttile
%        Mirko(M, TM, Events, "diam. (a.u.)", 0, 0)
%         title(["Original data"; "PSTH"])
    nexttile
        histogram(delta)
        xline([AVG+std_thresh*STD], "label", "std_thresh std"); hold on;
        xline([AVG-std_thresh*STD], "label", "std_thresh std")
%         xline([-3std_thresh], "label", "Hand picked -3std_thresh a.u.")
%         xline([3std_thresh], "label", "Hand picked 3std_thresh a.u.")
        title("Delta in original data")
        ylim([0, 15])
%     nexttile
%         Mirko(Copy, TM, Events, "diam. (a.u.)", 0, 0)
%         title(["Corrected data"; "PSTH"])
%     Samax = {[1, 2]}; 
%     SameYLim(gcf, Samax);
end
M = Copy;
end




