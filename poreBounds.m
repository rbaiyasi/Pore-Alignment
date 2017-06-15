function [ boundimg , CC ] = poreBounds( im , varargin )
%poreBounds Uses Canny edge detection and common-sense filtering to extract
%pore boundaries
%   INPUT:  im - input image.
%           varargin - { CannySigma ,
%                   CannySigma - standard deviation of the Gaussian filter
%                       used in the Canny filter. Defaults to sqrt(2).
%% Error Codes
noclosedError.identifier = 'pores:poreBounds:noClosedEdges';
noclosedError.message = 'No edges approximate closed circles about the origin';

%% varargin - { CannySigma ,
defargs = {sqrt(2)};
if nargin > 1
    arginds = find(~cellfun(@isempty,varargin));
    defargs(arginds) = varargin(arginds);
end
[CannySigma] = defargs{:};
%% Initial edge detection
[Y,X] = size(im);
bw1 = edge( im , 'Canny' , [] , CannySigma);

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
    tmpr = [tmpx,tmpy]; % pixel coordinates
    relr = tmpr - repmat(cpx,N,1);
    relr = relr(:,1) + 1i*relr(:,2); % convert to complex coords
    relang = wrapTo2Pi(angle(relr)); % get angle from center pixel
    [~,sortidx] = sort(relang);
    tmpr = tmpr(sortidx,:); % Sort coordinates by angle
    tmpr(N+1,:) = tmpr(1,:); % Add last coordinate to end for closed
    % Calculate distances between all adjacent points
    tmpdisp = tmpr(2:end,:) - tmpr(1:end-1,:);
    tmpdisp = sum(tmpdisp.^2,2);
    % Compare squared distance to maximum allowed (2)
    if max(tmpdisp) <= 2
%         disp([num2str(k), ' is closed'])
        closedflags(k) = true;
        CC.closed(k) = true;
    else
        CC.closed(k) = false;
    end
end
if sum(closedflags) == 0
    disp(noclosedError.message)
%     error(noclosedError);
end
    


