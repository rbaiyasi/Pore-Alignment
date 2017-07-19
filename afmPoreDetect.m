function [ pore_locs , nn_seprange , CC ] = afmPoreDetect( img_AFM , CannySigma)
%bfPoreDetect Uses input afm image and to pick out the most obvious pores 
%and return their locations.
%   INPUT:  img_AFM - cropped afm image
%           CannySigma - Sigma parameter for Canny edge detection. Defaults
%                   to sqrt(2);
%   OUTPUT: pore_locs - estimated pore centers for pores picked out by
%               convolution listed as [x,y] row vectors
if nargin < 2
    CannySigma = sqrt(2);
end
boundimg = edge(img_AFM , 'Canny' , [] , CannySigma);
CC = bwconncomp(boundimg);
blankimg = zeros(CC.ImageSize);
porelocs1 = zeros(CC.NumObjects,2);
for k = 1:CC.NumObjects
    tmpimg = blankimg;
    tmpimg(CC.PixelIdxList{k}) = 1;
    cpx = calcCofMass(tmpimg);
    [tmpy,tmpx] = ind2sub(CC.ImageSize,CC.PixelIdxList{k});
    if numel(CC.PixelIdxList{k}) < 10
        CC.closed(k) = false;
    else
        CC.closed(k) = isClosedPointsAboutCenter([tmpx,tmpy],cpx,8);
    end
    porelocs1(k,:) = cpx;
end
porelocs1 = porelocs1(CC.closed,:);
CC.PixelIdxList(~CC.closed) = [];
CC.NumObjects = numel(CC.PixelIdxList);
CC.closed = true(1,CC.NumObjects);

%% Return
pore_locs = porelocs1;
nn_seprange = [0,inf];
