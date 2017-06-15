function [ xy0 , R ] = poreFit2Circle( img )
%poreFit2Circle For input image (or stack of images), use Canny edge
%detection and circle fitting to find center and radius of largest closed,
%circular region about the origin. If there are no closed regions, will
%return NaN for center coordinates and radii.
%   INPUT:  img - 2D image (or 3D stack of images).
%   OUTPUT: xy0 - center of circles expressed as [x,y] row vectors.
%           R - radii of each circular fit.

