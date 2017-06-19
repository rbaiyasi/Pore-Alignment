function [ boundimg , CC ] = poreBounds( im , varargin )
%poreBounds Uses Canny edge detection and common-sense filtering to extract
%pore boundaries
%   INPUT:  im - input image.
%           varargin - { CannySigma , gapParam
%                   CannySigma - standard deviation of the Gaussian filter
%                       used in the Canny filter. Defaults to sqrt(2).
%                   gapParam - square of the largest separation allowed
%                       between 2 pixels when determining 'closedness'.
%                       Default of 2.
%% Error Codes
noclosedError.identifier = 'pores:poreBounds:noClosedEdges';
noclosedError.message = 'No edges approximate closed circles about the origin';

%% varargin - { CannySigma , gapParam
defargs = {sqrt(2) , 2};
if nargin > 1
    arginds = find(~cellfun(@isempty,varargin));
    defargs(arginds) = varargin(arginds);
end
[CannySigma , gapParam] = defargs{:};
%% Initial edge detection
[Y,X] = size(im);
if ~isnan(im(1))
    bw1 = edge( im , 'Canny' , [] , CannySigma);
else
    bw1 = ones(size(im));
end

%% Uses center-lines through cell array to filter out schmutz
bw2 = bw1;
% Vertical line
C = round(X/2);
midslice = bw2(:,C);
cnt = 0;
bwV = zeros(size(bw2));
try
    while sum(midslice) > 0 && cnt < 2*Y
        R = find(midslice,1);
        tmpbndry = bwtraceboundary(bw2,[R,C],'N');
        tmpinds = sub2ind([Y,X],tmpbndry(:,1),tmpbndry(:,2));
        bw2(tmpinds) = 0;
        bwV(tmpinds) = 1;
        midslice = bw2(:,C);
        cnt = cnt+1;
    end

    bw2 = bw1;
    R = round(Y/2);
    midslice = bw2(R,:)';
    cnt = 0;
    bwH = zeros(size(bw2));
    while sum(midslice) > 0 && cnt < 2*X
        C = find(midslice,1);
        tmpbndry = bwtraceboundary(bw2,[R,C],'W');
        tmpinds = sub2ind([Y,X],tmpbndry(:,1),tmpbndry(:,2));
        bw2(tmpinds) = 0;
        bwH(tmpinds) = 1;
        midslice = bw2(R,:);
        cnt = cnt+1;
    end
catch ME
    if strcmp(ME.identifier,'images:bwtraceboundary:failedTrace') 
        disp(['Error ',ME.identifier])
        disp(ME.message)
        boundimg = bw2;
        return
    else
        error(ME)
    end
end
boundimg = bwH.*bwV;
%% Use bwconncomp and imfill to check for closed paths
CC = bwconncomp(boundimg);
closedflags = false(1,CC.NumObjects);
for k = 1:CC.NumObjects
    % Extract coordinates of on pixels
    [tmpy,tmpx] = ind2sub(CC.ImageSize,CC.PixelIdxList{k});
    N = numel(tmpx);
    cpx = round(CC.ImageSize/2); % center pixel
    CC.closed(k) = isClosedPointsAboutCenter([tmpx,tmpy],cpx,gapParam);
    closedflags(k) = CC.closed(k);
end
if sum(closedflags) == 0
    warning(noclosedError.message)
%     error(noclosedError);
end
    


