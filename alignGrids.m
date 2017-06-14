function [ theta_hat ] = alignGrids( p0s , p1s )
%alignGrids Aligns a set of correlated points using rotation, scaling, and
%translation
%   INPUT:  p0s(p1s) - matrix of [x,y] row vectors where the points are
%               correlated with each other. p0s are the locked points,
%               while p1s are the points that are fit to p0s.
%   OUTPUT: tfParams - structure containing the various transformations p1s
%               must undergo to best fit p0s
