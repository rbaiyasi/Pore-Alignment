function [ outptlist , filterParams ] = filterByNN( ptlist )
%filterByNN Takes an input set of points and filters out the ones that
%don't fit into a grid-like scheme.
%   INPUT:  ptlist - Nx2 array or [x,y] row vectors. It is assumed that
%               there is enough consistency that the regularity of the map
%               can be extracted.
N = size(ptlist,1);

% Convert to complex coordinates.
pts = ptlist(:,1) + 1i*ptlist(:,2);
dispmat = genDispmat(pts);
% Use the median of the smallest separations between points to estimate
% nearest-neighbor separations.
sepmat = abs(dispmat);
sortsepmat = sort(sepmat,1);
minseps = sortsepmat(1,:);
% Using median of distributed minimum steps and 0.10 of the median as the
% standard deviation to extract appropriate points.
[~,sortIdx] = sort(minseps);
medianIdx = sortIdx(round(N/2));
mu3 = minseps(medianIdx);
sig3 = 0.1*mu3;
std_fact = 1;
mu = mu3;
sig = sig3;

% Pick out angle between nearest neighbors
% nnmat = abs(sepmat-mu) <= std_fact*sig;
% activeNNs = dispmat(nnmat);
% activeAngs = angle(activeNNs);
% anglestates = stasiAnalysisR(activeAngs');
% anglestates.num_levels
nnvect = sum(abs(sepmat-mu) <= std_fact*sig);
pts2keep = nnvect > 1; % needs at least two nearest neighbors;
%% Return
outptlist = ptlist(pts2keep,:);
filterParams.mu = mu;
filterParams.sigma = sig;