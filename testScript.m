%% testScript 
%% Load Data - optional choice between large or small pores
% Pore size is manually input here - this will probably be the last step
clearvars
load BF_area14_crop
init_rad = 19;

% load small_pores1_crop
% init_rad = 10;

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
text(porelocs(:,1),porelocs(:,2),tmpnums,'r');
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
    plot(xxH,yyH,'k');
end
yyV = [1,Y]; % Vertical lines
tVlines = transLine(Vlines); % transpose for ease of plotting
for k = 1:size(Vlines,2)
    xxV = tVlines(1,k)*yyV + tVlines(2,k);
    plot(xxV,yyV,'k')
end
hold off


%% from grid intersections, get refined pore localizations
% Needs work. It is important that there is a defined way to translate
% refined localizations in the roi back to the final image.
% useful values from line data
vseps = abs((Vlines(2,2) - Vlines(2,1))/Vlines(1,1));
hseps = abs(Hlines(2,2) - Hlines(2,1));
% define sub-grid with middle selection of grid points
V = size(Vlines,2) - 2;
H = size(Hlines,2) - 2;
if H < 2 || V < 2
    error('Not enough grid points')
end
sub_grid_pts = calcGridIntersections(Hlines(:,2:end-1),Vlines(:,2:end-1));
numgp = size(sub_grid_pts,1);

boxrad = floor(min(vseps,hseps)/2) - 1;
boxsize = 2*boxrad + 1;
clearvars img_rois
porerois(numgp).ul = [];
porerois(numgp).img = [];
img_rois = zeros( boxsize , boxsize , numgp );
for k = 1:numgp
    ul = round(sub_grid_pts(k,:) - boxrad);
    lr = ul+boxsize - 1;
    tmpim2 = crop(bf,ul,lr);
    img_rois(:,:,k) = tmpim2;
    porerois(k).ul = ul;
    porerois(k).img = tmpim2;
end

mov = makeimmovie(img_rois);
% implay(mov)

%% Testing pore localization through circular fitting
k = 1;
tic
for k = 1:numgp
cthd = [];
csigma = sqrt(2);
tmpimg = porerois(k).img;
tmpedges = edge(tmpimg,'Canny',cthd,csigma);
[tmpedges,CC] = poreBounds(tmpimg,csigma);
[B,L] = bwboundaries(tmpedges,'noholes');
end
toc
% CC = bwconncomp(tmpedges)
figure(1)
imagesc(tmpimg); axis image
setFont
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end
hold off

% figure(2)
% imagesc(tmpedges)
% axis image
% setFont

% bw2 = tmpedges;
% [Y,X] = size(tmpimg);
% C = round(X/2);
% midslice = bw2(:,C);
% testregs = {};
% cnt = 0;
% while sum(midslice) > 0 && cnt < 1e6
%     R = find(midslice,1);
%     tmpbndry = bwtraceboundary(bw2,[R,C],'N');
%     tmpinds = sub2ind([Y,X],tmpbndry(:,1),tmpbndry(:,2));
%     bw2(tmpinds) = 0;
%     testregs = [testregs,{tmpinds}];
%     midslice = bw2(:,C);
%     cnt = cnt+1;
% end
%  
% sizethresh = 50;
% currsizes = cellfun(@numel,testregs);
% testregs = testregs(currsizes >= sizethresh);


