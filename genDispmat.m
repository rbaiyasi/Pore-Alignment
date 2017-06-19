function [ dispmat , xdispmat , ydispmat ] = genDispmat( ptslist )
%pointSeparations Takes and input of row-vector points and creates a
%displacement map to be used for nearest-neigbor calculations and the like.
%   INPUT:  ptslist - MxD matrix, where M is the number of points and D is
%               the dimensionality of the data. If D is one and it is a
%               complex vector, returns complex dispmat. If D is one and it
%               is a real-valued vector, return magnitude dispmat.
%   OUTPUT: dispmat - MxM matrix of displacements between each points. The
%               diagonals are set to zero to avoid the minimum of zero.
%           xdispmat(ydispmat) - MxM matrix of x(y) separations between
%               points. Diagonals are set to NaN.
[N,D] = size(ptslist);
switch D
    case 2
        % standard separations if two-element vectors
        x0s = ptslist(:,1);
        y0s = ptslist(:,2);
        % Distances between all points. Ignore self-distance of zero
        xxmat = repmat(x0s,1,N);
        yymat = repmat(y0s,1,N);
        xdispmat = abs(xxmat - xxmat');
        xdispmat(logical(eye(N))) = NaN;
        ydispmat = abs(yymat - yymat');
        ydispmat(logical(eye(N))) = NaN;
        dispmat = sqrt(xdispmat.^2+ydispmat.^2);
    case 1
        % single column input assumed to be complex
        rrmat = repmat(ptslist(:),1,N);
        dispmat = rrmat - rrmat.'; % Column gives origin point
        dispmat(logical(eye(N))) = NaN;
        if isreal(dispmat)
            dispmat = abs(dispmat);
        end
        xdispmat = [];
        ydispmat = [];
    otherwise
        error('Invalid input format')
end
    

