function [ NNdists , NNangs , resortIdx ] = getNNparams( centerpt, ptslist )
%getNNparams Sorts out points into a '+' shape with one point in the center
%NOTE--results are sorted as right,left,up,down
%   INPUT:  centerpt - [x,y] row vector of central point
%           ptslist - list of [x,y] row vectors of nearest-neighbors
%   OUTPUT: NNdists - pixel distances between each neighbor
%           NNangs - angle in radians to each neighbor
%           resortIdx - indices used to reassign points. Note that a dummy
%               index (1 greater than the number of pts in ptslist) will be
%               assigned to each missing point.
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
NNidxFields = {'r','l','u','d'};
NNidx.r = find(real(NNdisps) > 0 & abs(real(NNdisps)) >= abs(imag(NNdisps)));
NNidx.l = find(real(NNdisps) < 0 & abs(real(NNdisps)) >= abs(imag(NNdisps)));
NNidx.u = find(imag(NNdisps) > 0 & abs(real(NNdisps)) < abs(imag(NNdisps)));
NNidx.d = find(imag(NNdisps) < 0 & abs(real(NNdisps)) < abs(imag(NNdisps)));

%% Checking condition and validity
% check how many pts were assigned to each NN position
numinpos = structfun(@numel,NNidx);
if max(numinpos) > 1
    error(toomanyinPtError)
end

% if one of the NN positions was not filled, assign it a dummy index
unassignedidx = find(numinpos == 0);
if numel(unassignedidx) > 0
    for k = 1:numel(unassignedidx)
        NNidx.(NNidxFields{unassignedidx(k)}) = numNN + k;
        NNdist(numNN + k,:) = NaN;
        NNang(numNN + k,:) = NaN;
    end
%     NNdist(numNN + 1,:) = NaN;
%     NNang(numNN + 1,:) = NaN;
end

% check if any were assigned more than once, ignoring the dummy index
allNNidx = structfun(@single,NNidx);
tmpNNidx = allNNidx;
tmpNNidx(allNNidx == numNN + 1) = []; % remove dummy indices
if ~isequal(unique(tmpNNidx),sort(tmpNNidx))
    error(repeatePtError);
end
%% Return Values
NNdists = NNdist(allNNidx);
NNangs = NNang(allNNidx);
% Wrap angle of definition to improve averaging
NNangs(1,:) =  wrapToPi(NNangs(1,:));
NNangs(2,:) = wrapTo2Pi(NNangs(2,:));
resortIdx = allNNidx;
% resortIdx(resortIdx == numNN + 1) = 0;

