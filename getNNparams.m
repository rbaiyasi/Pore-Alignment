function [  ] = getNNparams( centerpt, ptslist )
%getNNparams Sorts out points into a '+' shape with one point in the center
%   INPUT:  centerpt - [x,y] row vector of central point
%           ptslist - list of [x,y] row vectors of nearest-neighbors
%% Error Codes
repeatPtError.message = 'A nearest-neigbor has been sorted into two positions';
toomanyinPtError.message = 'More than one nearest-neighbor has been assigned to one position';
nnMissortedError.message = 'Nearest-neighbor sorting mis-match. Ensure grid array is not be tilted 45 degrees.';
nnMissortedError.identifier = 'MATLAB:nnMissorted';

%% Setting up points for analysis
numNN = size(ptslist,1);
NNdisps = ptslist - repmat(centerpt,numNN,1);
% Convert to complex number to make angle stuff easier
NNdisps = NNdisps(:,1)+1i*NNdisps(:,2);
NNdist = abs(NNdisps);
NNang = angle(NNdisps);

%% Deal with everything in terms of indices for now
% left/right and up/down nearest neigbors can be distinguished by whether 
% the real or imaginary part is bigger, respectively. As long as we are not
% close to 45 degrees, this should be fine.
% for example, the right nearest neigbor is the neighbor with a positive
% real part that is larger than the imaginary part
rNNidx = find(real(NNdisps) > 0 & abs(real(NNdisps)) >= abs(imag(NNdisps)));
lNNidx = find(real(NNdisps) < 0 & abs(real(NNdisps)) >= abs(imag(NNdisps)));
uNNidx = find(imag(NNdisps) > 0 & abs(real(NNdisps)) < abs(imag(NNdisps)));
dNNidx = find(imag(NNdisps) < 0 & abs(real(NNdisps)) < abs(imag(NNdisps)));

%% Checking condition and validity


