function [ hLines , vLines ] = gridFromLocs( porelocs , nn_seprange )
%gridFromLocs Takes input porelocs along with accepted range for
%nearest-neighbor separations in order to calculate the horizontal and
%vertical gridlines that intially approximate it.
%   INPUT:  porelocs - [x,y] row vectors.
%           nn_seprange - [min_sep , max_sep] used the threshold nearest
%               neighbors from the rif-raf.
%   OUTPUT: hLines(vLines) - the sets of parallel lines that are close to
%               horizontal(vertical) to initialize the grid.


