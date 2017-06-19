clearvars
afmPath = 'Z:\Files for Rashad\Correlated_AFM_BF_images';
bfPath = afmPath;
[FileName , PathName] = uigetfile('*.tif','Choose AFM image',afmPath);
if ~FileName
    error('No AFM selected');
end
img_AFM = imread([PathName,FileName]);
ul_AFM = [69,73];
lr_AFM = [1092,1096];
img_AFM = crop(img_AFM,ul_AFM,lr_AFM);
img_AFM = mean(img_AFM,3);

%% Initial figures
% Do background subtraction
% bg = imopen(img_AFM,strel('disk',round(100)));
% img_AFM2 = img_AFM - bg;
% figure(1)
% imagesc(img_AFM2);
% axis image

[aY,aX] = size(img_AFM);
%% get porelocs1
boundimg = edge(img_AFM,'Canny' , [] , sqrt(2));
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
        CC.closed(k) = isClosedPointsAboutCenter([tmpx,tmpy],cpx,18);
    end
    porelocs1(k,:) = cpx;
end
porelocs1 = porelocs1(CC.closed,:);
CC.PixelIdxList(~CC.closed) = [];
CC.NumObjects = numel(CC.PixelIdxList);
CC.closed = true(1,CC.NumObjects);



%% get NN_seprange
nn_seprange = getNNseprange(porelocs1,[],3);
% Filter out bad points
nnmu = mean(nn_seprange);
nnrng = nnmu-nn_seprange(1);
dispmat = genDispmat(porelocs1);
dispmat = abs(dispmat-nnmu);
dispmat = dispmat <= nnrng;
num_nn = sum(dispmat);
porelocs2 = porelocs1(num_nn >= 1,:);

figure(1); imagesc(img_AFM); axis image
hold on
scatter(porelocs2(:,1),porelocs2(:,2),50,'or')
hold off
    
[ Hlines , Vlines ] = gridFromLocs( porelocs2 , nn_seprange );
init_grid_pts = calcGridIntersections(Hlines,Hlines);

% Update Figure 1 for visualization
figure(1);
hold on
xxH = [1,aX]; % Horizontal lines
for k = 1:size(Hlines,2)
    yyH = Hlines(1,k)*xxH + Hlines(2,k);
    plot(xxH,yyH,'--k');
end
yyV = [1,aY]; % Vertical lines
tVlines = transLine(Vlines); % transpose for ease of plotting
for k = 1:size(Vlines,2)
    xxV = tVlines(1,k)*yyV + tVlines(2,k);
    plot(xxV,yyV,'--k')
end
hold off

[ extractedROIs ] = extractPoreImgsFromGrid( img_AFM , Hlines , Vlines , 1);


% Create movie of ROI images
mov = makeimmovie(extractedROIs.imgs);
% implay(mov)

%% Testing pore localization through circular fitting
[ xy0 , R ] = poreFit2Circle( extractedROIs.imgs );


% Add refined pore positions to figure(1)
porelocs2 = extractedROIs.uls + xy0 - 1;
figure(1)
hold on
scatter(porelocs2(:,1),porelocs2(:,2),200,'+w')
viscircles(gca,porelocs2,R);
hold off

%% Fit pore locs to auto-generated grid to initialize alignment
% Number of horizontal and vertical lines
roiDims = extractedROIs.dims;
[Hs,Vs] = ind2sub(roiDims,(1:roiDims(1)*roiDims(2))');
porelbls = [num2str(Hs),repmat(',',numel(Hs),1),num2str(Vs)];
figure(1)
hold on
fontshift = 5;
text(porelocs2(:,1)+fontshift,porelocs2(:,2)+fontshift,porelbls,'Color','r','FontSize',14)
hold off