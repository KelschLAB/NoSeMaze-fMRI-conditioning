function [Array, Plo, Times] = InterpolateNaN(Array, Nans)
Plo = NaN(size(Array)); Times = 0;
there = 0; Reset = 0;
bec = 0; ome = 0;
fra = 0; til = 0;
for b = 1:numel(Array)
    if Reset == Nans
        there = 0; Reset = 0;
        bec = 0; ome = 0;
        fra = 0; til = 0;
    end
    if ~isnan(Array(b)) && there == 0
        fra = b;
        bec = Array(b);
    elseif isnan(Array(b)) && there == 0
        there = 1;
        Reset = 0;
    elseif isnan(Array(b)) && there == 1        
        Reset = Reset+1;
    elseif ~isnan(Array(b)) && there == 1
        if fra == 0 
            Reset = Nans;
            continue
        end
        til = b;
        ome = Array(b);
        Add = linspace(bec, ome, numel(fra:til));
        Plo(fra:til) = Add;
        Add = Add(2:end-1);
        Array(fra+1:til-1) = Add;
        Times = Times+1;
        Reset = Nans;
    end
end
end