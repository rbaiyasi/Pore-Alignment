%% testScript 
warning('off','all')
%% Load Data - optional choice between large or small pores
% Pore size is manually input here - this will probably be the last step
clearvars
load BF_area14_crop
init_rad = 18;

load small_pores1_crop
init_rad = 10;

%% Determine inital pore localizations through bfPoreDetect
[Y,X] = size(bf);
[ porelocs , nn_seprange ] = bfPoreDetect(bf,init_rad);
bg = imopen(bf,strel('disk',round(init_rad*1)));
BF = bf - bg;
% Figure for visualization of the points
figure(1)
imagesc(bf); axis image
setFont(20)
axis off
tmpnums = 1:size(porelocs,1);
tmpnums = cellstr(num2str(tmpnums'));
hold on
scatter(porelocs(:,1),porelocs(:,2),50,'r');
% text(porelocs(:,1),porelocs(:,2),tmpnums,'r');
hold off

%% Get initial grid lines from gridFromLocs, then get grid points
% Grid points are used to pick out regions of interest for refining pore
% localization in the next step.
[ Hlines , Vlines ] = gridFromLocs( porelocs , nn_seprange );
init_grid_pts = calcGridIntersections(Hlines,Hlines);

% Update Figure 1 for visualization
figure(1);
hold on
xxH = [1,X]; % Horizontal lines
for k = 1:size(Hlines,2)
    yyH = Hlines(1,k)*xxH + Hlines(2,k);
    plot(xxH,yyH,'--k');
end
yyV = [1,Y]; % Vertical lines
tVlines = transLine(Vlines); % transpose for ease of plotting
for k = 1:size(Vlines,2)
    xxV = tVlines(1,k)*yyV + tVlines(2,k);
    plot(xxV,yyV,'--k')
end
hold off


%% from grid intersections, get refined pore localizations
[ extractedROIs ] = extractPoreImgsFromGrid( bf , Hlines , Vlines , 1);


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

warning('on','all')