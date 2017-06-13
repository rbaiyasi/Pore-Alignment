function [  ] = getNNparams( centerpt, ptslist )
%getNNparams Sorts out points into a '+' shape with one point in the center
%   INPUT:  centerpt - [x,y] row vector of central point
%           ptslist - list of [x,y] row vectors of nearest-neighbors
numNN = size(ptslist,1);
NNdisps = ptslist - repmat(centerpt,numNN,1);
% Convert to complex number to make angle stuff easier
NNdisps = NNdisps(:,1)+1i*NNdisps(:,2);
NNdist = abs(NNdisps);
NNang = angle(NNdisps);

% Deal with everything in terms of indices for now
lrNNs = find(abs(real(NNdisps)) >= abs(imag(NNdisps)));
udNNs = find(abs(real(NNdisps)) < abs(imag(NNdisps)));
