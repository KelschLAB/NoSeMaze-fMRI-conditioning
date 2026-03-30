function [T p p2 fdrmat meanval stdab] = lei_ttest2( g1, g2, fdr, fisher )
% [T p p2 fdrmat meanval stdab] = lei_ttest2( g1, g2, fdr )
% http://www.mathworks.de/help/toolbox/stats/ttest2.html

if nargin < 4
    fisher=0;
end

if fisher
    for ix=1:length(g1)
        g1{ix}=0.5*log((1+g1{ix})./(1-g1{ix}));
        g1{ix}(isinf(g1{ix}))=1;
    end
    for ix=1:length(g2)
        g2{ix}=0.5*log((1+g2{ix})./(1-g2{ix}));
        g2{ix}(isinf(g2{ix}))=1;
    end
end

g1mat = cat( 3, g1{:} );
g2mat = cat( 3, g2{:} );

g1mean = mean( g1mat, 3 );
g2mean = mean( g2mat, 3 );

g1std = std( g1mat, 0, 3 );
g2std = std( g2mat, 0, 3 );

g1count = length( g1 );
g2count = length( g2 );

%T = (g1mean - g2mean) ./ sqrt( g1std .^2 / g1count + g2std .^2 / g2count );
Sx1x2=sqrt(((g1count-1)*g1std.^2+(g2count-1)*g2std.^2)/(g1count+g2count-2));
T=(g1mean-g2mean)./Sx1x2./sqrt(1/g1count+1/g2count); %wwf121128 from english wikipedia

meanval = {g1mean; g2mean};
stdab = {g1std; g2std};

%df = g1count - 1;
df = g1count + g2count - 2;

[p_2, p2_2] = getp( T, df );
% isequal( p(~isnan( p )), p_2(~isnan( p )) )
% isequal( p2(~isnan( p2 )), p2_2(~isnan( p )) )
p = p_2;
p2 = p2_2;


%get fdrmat
fdrmat = getFDR( p2, fdr );

end
 
%figure(10);plot(gamma((df+1)/2)/sqrt(df*pi)*gamma(df/2)*(1+T.^2/df).^((-df+1)/2))

function [p p2] = getp( T, df )

step=0.001

Tvec = -10:step:10;
pd = gamma( (df + 1) / 2 ) / sqrt( df * pi ) / gamma( df / 2 ) * (1 + Tvec .^ 2 / df) .^ (-(df + 1) / 2);

p = zeros( size( T ) );
for iT = 1:numel( T )
    p(iT) = 1 - sum( (Tvec < abs( T(iT) )) .* pd ) *step; % p ist das Integral von pd ober- oder unterhalb von T; da sym. abs(T)! und "1-sum.." dann korrekt.
end

p(p == 1) = NaN;
p2 = p .* 2;

end


function fdrmat = getFDR( p, fdr )

% nr = size( p, 1 );
% numberoftest = sum( 1:nr-1 );

% %lower triangle
% ps = tril( p );
% 
% %set nan as to 0
% ps(find(isnan(ps)))=0;

% lower triangle
% set nan as to 0
ps_2 = tril( p );
ps_2(isnan( ps_2 )) = 0;
% isequal( ps, ps_2 )
ps = ps_2;

% %[pv, px, py]=find(ps);
% %get nonzero elements in a vector       
[pix] = find( ps );
% pvec = ps(pix);

% get nonzero elements in a vector       
pvec_2 = ps(ps ~= 0);
% isequal( pvec, pvec_2 )
pvec = pvec_2;

% Sort Vector
[psort prank] = sort( pvec );
rank = 1:length( psort );
Q = rank' * fdr / length( psort );
%(psort<=rank'*0.05/length(psort));
pfdrix = find( (psort <= Q) & (psort < 0.1) );
x = zeros( length( pfdrix ), 1 );
y = zeros( length( pfdrix ), 1 );
for ix = 1:length( pfdrix )
    [x(ix), y(ix)] = ind2sub( size(p), pix( prank(ix) ) );
end
fdrmat = zeros( size( p ) );
for ix = 1:length( pfdrix )
    fdrmat(x(ix), y(ix)) = 1;
end

end
