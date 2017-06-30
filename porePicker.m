function [ Rs ] = porePicker( dataOrAx , imagemode )
%porePicker With an input image or figure with image, pick out a region
%with a pore and use it to find other pores in the image.
%   INPUT:  dataOrFig
%           imagemode - defaults to 'AFM'
IMAGEMODES = {'AFM','BF'};

%% Format inputs
if nargin < 2
    imagemode = IMAGEMODES{1};
end
if isgraphics(dataOrAx(1),'axes')
    ax1 = dataOrAx;
    fig1 = ax1.Parent;
    childs = allchild(ax1);
    imh = childs(find(isgraphics(childs,'Image'),1));
    Data1 = imh.CData;
elseif isnumeric(dataOrAx(1))
    Data1 = dataOrAx;
    fig1 = figure;
    ax1 = axes;
    imh = imagesc(Data1,'Parent',ax1);
    axis image
    setFont(14)
end

%% Get user input
valid_initpore = false;
while ~valid_initpore
    fig1.Name = 'Select a pore and hit enter';
    rh = imrect(ax1);
    set(fig1,'KeyPressFcn',@continueOnReturn);
    waitfor(fig1 , 'Name')
    cropbox = round(getPosition(rh));
    cropim = croprect(Data1,cropbox);
    [validflag , Rs] = isValidPore(cropim);
    if validflag
        valid_initpore = true;
    else
        delete(rh)
        clearvars Rs
    end
end
delete(rh)
% disp(['Estimated radius: ', num2str(Rs)])
%% Main body
switch imagemode
    case IMAGEMODES{1} %AFM
        
end

function continueOnReturn(h_obj,evt)
inkey = evt.Key;
if strcmp(inkey,'return')
    h_obj.Name = 'Pore selected';
end

function [ validflag , R ] = isValidPore(img)
gapParam = 2*3^2;
[ xy0 , R ] = poreFit2Circle( img , [] , gapParam);
% valid unless all of them are nan
validflag = ~isequal(sum(isnan(R)),numel(R));
