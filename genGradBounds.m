function [ outbound , inbound , dImag2 , BW ] = genGradBounds( img , varargin )
%genGradBounds Used to generate edges for AFM images of pores using
%gradient calculation between points to distinguish pore walls from flat
%regions.
%   INPUT:  img - input image of AFM pore.
%           varargin - {Canny_sigma}
%               Canny_sigma - Canny edge detection parameter. Default value
%                   of sqrt(10).
%   OUTPUT: outbound(inbound) - [x,y] row vectors of line tracing the
%               outer(inner) boundary.
%% varargin - {Canny_sigma
defargs = {sqrt(10)};
if nargin > 1
    arginds = find(~cellfun(@isempty,varargin));
    defargs(arginds) = varargin(arginds);
end
[Canny_sigma] = defargs{:};


I = img;
%% >> Taken from Radial Symmetry localization method by Parthasarathy
% Number of grid points
[Ny Nx] = size(I);
% xm_onerow = -(Nx-1)/2.0+0.5:(Nx-1)/2.0-0.5;
% xm = xm_onerow(ones(Ny-1, 1), :);
% ym_onecol = (-(Ny-1)/2.0+0.5:(Ny-1)/2.0-0.5)';  % Note that y increases "downward"
% ym = ym_onecol(:,ones(Nx-1,1));

% Calculate derivatives along 45-degree shifted coordinates (u and v)
% Note that y increases "downward" (increasing row number) -- we'll deal
% with this when calculating "m" below.
dIdu = I(1:Ny-1,2:Nx)-I(2:Ny,1:Nx-1);
dIdv = I(1:Ny-1,1:Nx-1)-I(2:Ny,2:Nx);

% Smoothing -- 
h = ones(3)/9;  % simple 3x3 averaging filter
fdu = conv2(dIdu, h, 'same');
fdv = conv2(dIdv, h, 'same');
dImag2 = fdu.*fdu + fdv.*fdv; % gradient magnitude, squared
%% << End adapted code
% Edge detection and tracing
BW = edge(dImag2,'Canny',[],Canny_sigma);
B = bwboundaries(BW);

% Check that there are 2 regions found. This may be altered later.
if numel(B) > 2 && numel(B) < 4
%     error('There are not 2 edges detected');
    disp(['There are only ',num2str(numel(B)), ' edges detected']);
elseif numel(B) == 0
    disp('No boundaries found')
    outbound = [];
    inbound = [];
    return
end

% Bounds are outside of larger circle and smaller circles
outbound = fliplr(B{1}) + 0.5;
inbound = fliplr(B{2}) + 0.5;