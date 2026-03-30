function [T p p2 fdrmat meanval stdab] = lei_pairedtt( g1, g2, fdr )
% [T p p2 fdrmat meanval stdab] = pairedtt( g1, g2, fdr )
% reformulated by Lei

% diffimages

% dg = cell( size( g1 ) );
% for ix = 1:length( g1 )
%     dg{ix} = g1{ix} - g2{ix};
% end
% 
% dmat = zeros( [size( dg{1} ), size( dg, 2 )] );
% for ix = 1:length(dg)
%     dmat(:, :, ix) = dg{ix};
% end

g1mat = cat( 3, g1{:} );
g2mat = cat( 3, g2{:} );
dmat_2 = g1mat - g2mat;
% isequal( dmat, dmat_2 )
dmat = dmat_2;

%
meanval = mean( dmat, 3 );
ns = length( g1 );
df = ns - 1;

%
% nr = size( dmat, 1 );
% stdab = zeros( nr );
% T = zeros( nr );
% p = zeros( nr );
% p2 = zeros( nr );
% 
% 
% for x = 1:size( dmat, 1 )
%     for y = 1:size( dmat, 2 )
%         series = squeeze( dmat(x, y, :) );
%         stdab(x, y) = std( series );
%         T(x, y) = meanval(x, y) / stdab(x, y) * sqrt( ns );
%         [p(x,y) p2(x,y)] = getp( T(x, y), df );
%     end
% end

stdab_2 = std( dmat, 0, 3 );
% isequal( stdab, stdab_2 )
stdab = stdab_2;

T_2 = meanval ./ stdab .* sqrt( ns );
% isequal( T(~isnan( T )), T2(~isnan( T )) )
T = T_2;

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

Tvec = -10:0.001:10;
pd = gamma( (df + 1) / 2 ) / sqrt( df * pi ) / gamma( df / 2 ) * (1 + Tvec .^ 2 / df) .^ (-(df + 1) / 2);

p = zeros( size( T ) );
for iT = 1:numel( T )
    p(iT) = 1 - sum( (Tvec < abs( T(iT) )) .* pd ) / 1000; % p ist das Integral von pd ober- oder unterhalb von T; da sym. abs(T)! und "1-sum.." dann korrekt.
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
