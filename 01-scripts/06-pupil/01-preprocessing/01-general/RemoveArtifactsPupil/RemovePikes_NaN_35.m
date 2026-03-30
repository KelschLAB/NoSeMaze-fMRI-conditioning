function [M, Removed] = RemovePikes_NaN_35(M, TM, Events, Thresh, IfPlot)
Copy = M;
Mask = ones(size(M)); Mask(isnan(M)) = NaN;
Plo = NaN(size(M));
delta = M(1, 2:end, :) - M(1, 1:end-1, :);
STD = std(delta(:, setdiff(1:size(delta,2), Events(3)-1), :), 0, "all", "omitnan"); AVG = mean(delta(:, setdiff(1:size(delta,2), Events(3)-1), :), "all", "omitnan");
OL = zeros(size(delta));
OL(delta<-35) = -1; OL(delta>+35) = 2; 
OL(1, Events(3)-1, :) = 0;
Removed = 0; 
for tr = 1:150
    win = 0; cou = 0;
    ver = 0; nichte = 0;
    for b = 1:167
        if cou == Thresh || b == Events(3)-1
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
OL(delta<-35) = -1; OL(delta>35) = -1; 
OL(1, Events(3)-1, :) = 0;
OL(isnan(delta)) = 2;
for tr = 1:150
    win = 0; cou = 0;
    ver = 0; nichte = 0;
    for b = 1:167
        if cou == Thresh || b == Events(3)-1
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
for tr = 1:150
    Times = 0;
    [Copy(1, :, tr), Pla(1, :, tr), Times] = InterpolateNaN(Copy(1, :, tr), Events, 5);
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
        xline([Events(1), Events(4), Events(6)], "k", "LineWidth", 2, "Alpha", 1)
        xline([Events(2), Events(5)], "--k", "LineWidth", 2, "Alpha", 1)
    nexttile
        plot(squeeze(M.*Mask));
        hold on
        plot(squeeze(Pla), "-r", "LineWidth", 2)
        title(["Corrected data, " + num2str(Removed) + " spikes removed"; " and " + num2str(Interpolated) + " interpolations where NaN (max 5 in row)"])
        xline([Events(1), Events(4), Events(6)], "k", "LineWidth", 2, "Alpha", 1)
        xline([Events(2), Events(5)], "--k", "LineWidth", 2, "Alpha", 1)    
%     nexttile
%        Mirko(M, TM, Events, "diam. (a.u.)", 0, 0)
%         title(["Original data"; "PSTH"])
    nexttile
        histogram(delta(:, setdiff(1:size(delta,2), Events(3)-1), :))
        xline([-35], "label", "Hand picked -35 a.u.")
        xline([35], "label", "Hand picked 35 a.u.")
        title("Delta in original data")
        ylim([0, 15])
    nexttile
        Mirko(M.*Mask, TM, Events, "diam. (a.u.)", 0, 0)
        title(["Corrected data"; "PSTH"])
    Samax = {[1, 2]}; 
    SameYLim(gcf, Samax);
end
M = Copy;
end




