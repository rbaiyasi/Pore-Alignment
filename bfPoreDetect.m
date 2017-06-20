function [ pore_locs , nn_seprange ] = bfPoreDetect( img_bf , rad_est )
%bfPoreDetect Uses input brightfield image and an estimated pore outer
%radius to pick out the most obvious pores and return their locations
%   INPUT:  img_bf - cropped brightfield image
%           rad_est - estimated outer radius of the pores
%   OUTPUT: pore_locs - estimated pore centers for pores picked out by
%               convolution listed as [x,y] row vectors

bf = double(img_bf);

%% preparing first convolution element
%Parameters for generating circle
numcircpts = 100; % Number of angular coords
% Generate unit circle
thetas = linspace(0,2*pi,numcircpts+1);
thetas = thetas(1:(end-1));
xs = cos(thetas); ys = sin(thetas);

rad1 = rad_est; % larger (bright circle)
rad2 = rad1-1; % smaller (dark circle)
rad3 = rad1-2; % smaller (bright filled)
boxrad = round(rad1*2);
boxres = ceil(2*boxrad+1); % size of img_test1
r0 = [0,0]+boxres/2+0.5; % center of img_test1

% outer circle
xs1 = round(rad1*xs+r0(1)); ys1 = round(rad1*ys+r0(2));
lininds1 = sub2ind(boxres*[1,1],ys1,xs1);
% inner circle
xs2 = round(rad2*xs+r0(1)); ys2 = round(rad2*ys+r0(2));
lininds2 = sub2ind(boxres*[1,1],ys2,xs2);
% most inner circle
xs3 = round(rad3*xs+r0(1)); ys3 = round(rad3*ys+r0(2));
lininds3 = sub2ind(boxres*[1,1],ys3,xs3);

% IMG_TEST1
img_test1 = zeros(boxres);
img_test1(lininds1) = 1;
img_test1(lininds2) = -1;
img_testtmp = false(boxres);
img_testtmp(lininds3) = true;
img_testtmp = imfill(img_testtmp,round([1,1]*boxres/2));
img_test1(img_testtmp) = 0.25;

%% convolve with brightfield image to get initial pore locations
% calculate non-uniform background for subtraction (to improve convolution)
bg = imopen(bf,strel('disk',round(rad1*1)));
BF = bf - bg;
convim = conv2(BF,img_test1); % Convolve first time
convim = wkeep(convim,size(BF)); % Trim down size
% Extract local maxima of the image
[ lm_idx,~ ] = find_locmax( convim ,round(rad1*2) , 'none' );
% INITIAL PORE LOCATIONS
[lm_row,lm_col] = ind2sub(size(BF),lm_idx);

%% Create img_test2 for location refinement
% Prepare to loop over local maxima to extract images
inds2use = [];
roi_im = zeros(boxres,boxres,numel(lm_row));
for k = 1:numel(lm_row)
    ul = [lm_col(k),lm_row(k)] - boxrad;
    lr = [lm_col(k),lm_row(k)] + boxrad;
    % only add image to stack if it is far enough from edges
    cropim = crop(BF,ul,lr);
%     if sum(ul>=1) + sum(lr<=size(BF,1)-1)==4
    if isequal(size(cropim),[boxres,boxres])
        roi_im(:,:,k) = cropim;
%         roi_im(:,:,k) = crop(BF,ul,lr);
        inds2use = [inds2use,k];
    else
        roi_im(:,:,k) = zeros(boxres);
    end
end
% remove the blank images for points close to boundaries
roi_im = roi_im(:,:,inds2use);
meanroi = (mean(roi_im,3));
% Calculate MSE between each image and the mean
errval = zeros(1,numel(inds2use));
for k = 1:numel(inds2use)
    errval(k) = squeeze(sum(sum((roi_im(:,:,k)-meanroi).^2)));
end
% Sort by increasing error
[errval , sortedids] = sort(errval);
roi_im = roi_im(:,:,sortedids);
% Only use the 'best' third of them to calculate img_test2
num2keep = ceil(numel(sortedids)/3);

% IMG_TEST2
img_test2 = mean(roi_im(:,:,1:num2keep),3);

%% convolve with brightfield image to get second-pass pore locations
convim2 = conv2(BF,img_test2);
convim2 = wkeep(convim2,size(BF)); % trim down to size(BF)
[ lm_idx2,lm_ints2 ] = find_locmax( convim2 ,round(rad1*2) , 'none' );

% X,Y COORDS FOR SECOND-PASS LOCALIZATIONS
% [ys1,xs1] = ind2sub(size(BF),lm_idx);
[ys2,xs2] = ind2sub(size(BF),lm_idx2);

%% Use regularity of pore spacing to filter out false pores
x0s = xs2(:);
y0s = ys2(:);
ptslist = [x0s,y0s];
dispmat = genDispmat(ptslist);
% Use the nearest-neigbor of each candidate to estimate pore spacing 
minvals = min(dispmat);

std_fact = 2;
[mu1,std1] = extractBGstats(minvals,std_fact);
nnmat = dispmat - mu1;
nnstd_fact = 3;
nnmat = abs(nnmat) < std1*nnstd_fact;
numnn = sum(nnmat);

nn_seprange = [-1,1]*nnstd_fact*std1 + mu1;
% Only pass pts with at least 2 neighbors
pts2keep = find(numnn >= 2);
pore_locs = [x0s(pts2keep),y0s(pts2keep)];