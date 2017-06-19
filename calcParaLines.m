function [ all_lines ] = calcParaLines( in_line , ptslist )
%calcParaLines With input horizontal line and list of points, calculates
%the set of all parallel lines that set up one direction of the initial
%grid.
%   INPUT:  inline - input line in the form [slope;intercept]. Should be a
%               fairly horizontal line.
%           ptslist - list of points as [x,y] row vectors.
%   OUTPUT: all_lines - sorted output of lines formatted as column vectors
%               of form [slope;intercept]. All slopes will be equal.
%% Error Codes
stdHsepsError.message = 'Line separations not consistent';
stdHsepsError.identifier = 'pores:calcParaLines:inconsistentSeparations';
%% Threshold definition
thd_stdHseps = inf; %Arbitrary right now

%% Calculating line spacings
m0 = in_line(1);
b0 = in_line(2);

% points of interest on the line
xx = ptslist(:,1);
yy = xx*m0 + b0;

% vertical distances from the line
ydisps = ptslist(:,2) - yy;
[ ydisps , sortidx ] = sort(ydisps);
stasiH = stasiAnalysisR(ydisps');
% Hlevels currently assumed to include all rows - needs to be tested
Hlevels = stasiH.levels;
Hseps = Hlevels(2:end) - Hlevels(1:end-1);

Hoffset = mean(Hseps);
% Use threshold to ensure the lines are close enough together to warrent
% using the mean as a line spacing parameter.
if std(Hseps) > thd_stdHseps
    disp(['Std. dev. in separations = ', num2str(std(Hseps))]);
    error(stdHsepsError);
end

%% Calculating lines
% This can be updated for more elegent methods later, but for now it
% functions using the closest-to-zero position to anchor the grid, and
% moves up and down from there to define the lines.
[ ~ , startidx ] = min(abs(Hlevels)); % define starting row
b1 = Hlevels(startidx);
num_below = sum( Hlevels < b1 ); % number of rows below
num_above = sum( Hlevels > b1 ); % number of rows above
% generate all the intercepts at once
bs = b0 + b1 + Hoffset * ( -num_below:1:num_above );
all_lines(2,:) = bs;
all_lines(1,:) = m0;