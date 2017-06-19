function [ dispmat , xdispmat , ydispmat ] = genDispmat( ptslist )
%pointSeparations Takes and input of row-vector points and creates a
%displacement map to be used for nearest-neigbor calculations and the like.
%   INPUT:  ptslist - MxD matrix, where M is the number of points and D is
%               the dimensionality of the data.
%   OUTPUT: dispmat - MxM matrix of displacements between each points. The
%               diagonals are set to zero to avoid the minimum of zero.
%           xdispmat(ydispmat) - MxM matrix of x(y) separations between
%               points. Diagonals are set to NaN.
x0s = ptslist(:,1);
y0s = ptslist(:,2);
N = numel(x0s);
% Distances between all points. Ignore self-distance of zero
xxmat = repmat(x0s,1,numel(x0s));
yymat = repmat(y0s,1,numel(y0s));
xdispmat = abs(xxmat - xxmat');
xdispmat = xdispmat * eye(N)*NaN;
ydispmat = abs(yymat - yymat');
ydispmat = ydispmat * eye(N)*NaN;
dispmat = sqrt(xdispmat.^2+ydispmat.^2);

