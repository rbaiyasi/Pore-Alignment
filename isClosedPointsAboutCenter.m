function [ closedflag ] = isClosedPointsAboutCenter( ptlist , xy0 )
%isClosedPointsAboutCenter Calculates for a set of points about a defined
%origin whether they form a closed, circular shape.
%   INPUT:  ptlist - Nx2 matrix of [x,y] row vectors describing the points.
%           xy0 - [x,y] row vector of the center coordinate.

