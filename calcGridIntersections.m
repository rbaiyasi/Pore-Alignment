function [ ptslist ] = calcGridIntersections( hLines , vLines )
%calcGridIntersections Finds the points the correspond to the intersection
%of a set of grid lines
%   INPUT:  hLines(vLines) -  close to horizontal(vertical) lines expressed
%               as [slope;intercept] column vectors, where slopes match.
%   OUTPUT: ptslist - intersection points of the grid as [x,y] row vectors
%               listed in the order of linear indexing.
% Based on the concept that for two lines,
% x_intersection=(b_v-b_h)/(m_h-m_v)
mh = hLines(1);
mv = vLines(1);

bh = hLines(2,:);
bv = vLines(2,:);

denom = 1/(mh-mv); % to speed calculation

H = size(hLines,2);
V = size(vLines,2);
ptslist = zeros(H*V,2);

for v = 1:V
    for h = 1:H
        xtmp = (bv(v)-bh(h)) * denom;
        ytmp = mv*xtmp + bv(v);
        linind = H*(v-1)+h;
        ptslist(linind,:) = [xtmp,ytmp];
    end
end

