function [  ] = getNNparams( centerpt, ptslist )
%getNNparams Sorts out points into a '+' shape with one point in the center
%   INPUT:  centerpt - [x,y] row vector of central point
%           ptslist - list of [x,y] row vectors of nearest-neighbors
numNN = size(ptslist,1);
NNdisps = ptslist - repmat(centerpt,numNN,1);
disp(NNdisps)