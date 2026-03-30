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
