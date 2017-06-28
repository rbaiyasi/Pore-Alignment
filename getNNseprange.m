function [ nn_seprange ] = getNNseprange( ptslist , varargin )
%getNNseprange Calculates acceptable separation range for nearest
%neighbors.
%   INPUT:  ptslist - locations of pores listed as [x,y] row vectors
%           varargin - { std_fact , nnstd_fact }
%                       std_fact - number of standard deviations to use for
%                           determining the expected minimum separation.
%                           Defaults to 2.
%                       nnstd_fact - number of standard deviations of the
%                           calculated separations to include in. Defaults
%                           to 3.
%% varargin - { std_fact , nnstd_fact }
defargs = { 2 ,3 };
if nargin > 1
    arginds = find(~cellfun(@isempty,varargin));
    defargs(arginds) = varargin(arginds);
end
[ std_fact , nnstd_fact ] = defargs{:};
dispmat = genDispmat(ptslist);
% Use the nearest-neigbor of each candidate to estimate pore spacing 
minvals = min(dispmat);
minvals = minvals(~isnan(minvals)); % eliminate nan points
[mu1,std1] = extractBGstats(minvals,std_fact);
nn_seprange = [-1,1]*nnstd_fact*std1 + mu1;

