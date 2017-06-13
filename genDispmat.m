function [ dispmat ] = genDispmat( ptslist )
%pointSeparations Takes and input of row-vector points and creates a
%displacement map to be used for nearest-neigbor calculations and the like.
%   INPUT:  ptslist - MxD matrix, where M is the number of points and D is
%               the dimensionality of the data.
%   OUTPUT: dispmat - MxM matrix of displacements between each points. The
%               diagonals are set to zero to avoid the minimum of zero.
x0s = ptslist(:,1);
y0s = ptslist(:,2);

% Distances between all points
xxmat = repmat(x0s,1,numel(x0s));
yymat = repmat(y0s,1,numel(y0s));
xdiff2 = (xxmat - xxmat').^2;
ydiff2 = (yymat - yymat').^2;
dispmat = sqrt(xdiff2+ydiff2);
dispmat(dispmat == 0 ) = NaN; % Ignore self-distance of zero

