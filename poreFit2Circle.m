function [ xy0 , R ] = poreFit2Circle( img , varargin)
%poreFit2Circle For input image (or stack of images), use Canny edge
%detection and circle fitting to find center and radius of largest closed,
%circular region about the origin. If there are no closed regions, will
%return NaN for center coordinates and radii.
%   INPUT:  img - 2D image (or 3D stack of images).
%           varargin - { CannySigma , gapParam
%                   CannySigma - standard deviation of the Gaussian filter
%                       used in the Canny filter. Defaults to sqrt(3).
%                   gapParam - square of the largest separation allowed
%                       between 2 pixels when determining 'closedness'.
%                       Default of 2.
%   OUTPUT: xy0 - center of circles expressed as [x,y] row vectors.
%           R - radii of each circular fit.
minboundsize = 0; %not used right now
%% varargin - { CannySigma , gapParam
defargs = {sqrt(3) , 2};
if nargin > 1
    arginds = find(~cellfun(@isempty,varargin));
    defargs(arginds) = varargin(arginds);
end
[CannySigma , gapParam] = defargs{:};

%% Main Loop
[ Y , X , N ] = size(img);
xy0 = zeros(N,2);
R = zeros(N,1);
for n = 1:N
    clearvars bw1 CC
    im1 = img(:,:,n);
    % Get the pore boundaries with initial filtering
    [ bw1 , CC ] = poreBounds(im1 , CannySigma);
    % Choose the largest closed boundary to continue
    if sum(CC.closed) > 0
        % Find the closed boundary with the most pixels in it
        boundsize = cellfun(@numel,CC.PixelIdxList);
        boundsize = boundsize .* CC.closed;
        [maxboundsize,idx2use] = max(boundsize);
        if maxboundsize < minboundsize
            xc = NaN;
            yc = NaN;
            tmpR = NaN;
        else
            % Use coordinates of boundary pixels to estimate fit circle
            [y,x] = ind2sub(CC.ImageSize,CC.PixelIdxList{idx2use});
            [xc,yc,tmpR] = circfit(x,y);
        end
    else % if there are no closed boundaries, return NaNs
        xc = NaN;
        yc = NaN;
        tmpR = NaN;
    end
    xy0(n,:) = [xc,yc];
    R(n) = tmpR;
end
    
    
    