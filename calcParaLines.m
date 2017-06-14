function [ all_lines ] = calcParaLines( in_line , ptslist )
%calcParaLines With input horizontal line and list of points, calculates
%the set of all parallel lines that set up one direction of the initial
%grid.
%   INPUT:  inline - input line in the form [slope;intercept]. Should be a
%               fairly horizontal line.
%           ptslist - list of points as [x,y] row vectors.
%   OUTPUT: all_lines - sorted output of lines formatted as column vectors
%               of form [slope;intercept]. All slopes will be equal.

m0 = in_line(1);
b0 = in_line(2);

