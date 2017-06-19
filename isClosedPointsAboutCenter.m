function [ closedflag ] = isClosedPointsAboutCenter( ptlist , xy0 , gapParam )
%isClosedPointsAboutCenter Calculates for a set of points about a defined
%origin whether they form a closed, circular shape.
%   INPUT:  ptlist - Nx2 matrix of [x,y] row vectors describing the points.
%           xy0 - [x,y] row vector of the center coordinate.
%           gapParam - Defaults to 2. Square of distance between pixels for
%               them to be considered adjacent. 
if nargin < 3
    gapParam = 2;
end
N = size(ptlist,1);

relr = ptlist - repmat(xy0,N,1);
relr = relr(:,1) + 1i*relr(:,2); % convert to complex coords
relang = wrapTo2Pi(angle(relr)); % get angle from center pixel
% Return false for points that are too close to the center
% reldist = abs(relr);
% if min(reldist) < sqrt(2)
%     closedflag = false;
%     return
% end
[~,sortidx] = sort(relang);
ptlist = ptlist(sortidx,:); % Sort coordinates by angle
ptlist(N+1,:) = ptlist(1,:); % Add last coordinate to end for closed
% Calculate distances between all adjacent points
tmpdisp = ptlist(2:end,:) - ptlist(1:end-1,:);
tmpdisp = sum(tmpdisp.^2,2);
% Compare squared distance to maximum allowed (2)
if max(tmpdisp) <= gapParam
    closedflag = true;
else
    closedflag = false;
end