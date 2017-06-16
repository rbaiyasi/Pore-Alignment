function [ extractedROIs ] = extractPoreImgsFromGrid( full_img , Hlines , Vlines , varargin )
%extractPoreImgsFromGrid Uses two sets of parallel lines to extract images from
%the intersection points and fit to a circular model.
%   INPUT:  full_img - Image to extract pore sub-images from.
%           Hlines(Vlines) - set of parallel lines listed as [m;b] column
%               vectors which are close to being horizontal(vertical);
%           varargin - {bordersize,
%                       bordersize - number of rows/columns to remove from
%                           the outside edge (to avoid overlapping with
%                           image boundary). Defaults to 1.
%   OUTPUT: extractedROIs - scalar structure with field 'imgs' containing
%               the extracted images as a SxSxN array of SxS images; and
%               field 'uls' as a Nx2 array of [x,y] pixel coordinates for
%               the top corner of each image.
%% Error Definitions
notEnoughError.identifier = pores:extractPoreImgsFromGrid:notEnoughPores;
notEnoughError.message = 'Need at least 2 row and 2 columns in sub-grid';
%% varargin - {bordersize,
defargs = {1};
if nargin > 2
    arginds = find(~cellfun(@isempty,varargin));
    defargs(arginds) = varargin(arginds);
end
[bordersize] = defargs{:};
%% Main function
% Get cartesian separation between horizontal and vertical lines.
hseps = abs(Hlines(2,2) - Hlines(2,1));
vseps = abs((Vlines(2,2) - Vlines(2,1))/Vlines(1,1));
% Define sub-grid by removing rows and columns from each side.
V = size(Vlines,2) - 2*bordersize;
H = size(Hlines,2) - 2*bordersize;
if H < 2 || V < 2
    % Function will not progress if there are not at least 2 rows and
    % columns.
    error(notEnoughError)
end
sub_grid_pts = calcGridIntersections(Hlines(:,2:end-1),Vlines(:,2:end-1));
num_gridpts = size(sub_grid_pts,1);

% Define size of square area to crop around each grid intersection based on
% the smallest horizontal or vertical separation based on grid angle.
cropbox_rad = floor(min(vseps,hseps)/2) - 1;
cropbox_size = 2*cropbox_rad + 1;

img_rois = zeros( cropbox_size , cropbox_size , num_gridpts );
uls = zeros(num_gridpts,2);
for k = 1:num_gridpts
    ul = round(sub_grid_pts(k,:) - cropbox_rad);
    lr = ul+cropbox_size - 1;
    tmpim2 = crop(full_img,ul,lr);
    img_rois(:,:,k) = tmpim2;
    uls(k,:) = ul;
end

% Combine images and upper-left coordinates into a scalar structure.
extractedROIs.imgs = img_rois;
extractedROIs.uls = uls;