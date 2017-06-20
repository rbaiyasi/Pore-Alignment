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
img_AFM = img_AFM-mean(img_AFM(:));


[aY,aX] = size(img_AFM);
%% get porelocs1
[ pore_locs , nn_seprange , CC] = afmPoreDetect( img_AFM );
[porelocs1 , filterParams] = filterByNN(pore_locs);

%% get porelocs2 using convolution
%estimate radius
for k = 1:CC.NumObjects
    [y,x] = ind2sub(CC.ImageSize,CC.PixelIdxList{k});
    [xc,yc,tmpR] = circfit(x,y);
    xy0(k,:) = [xc,yc];
    R(k) = tmpR;
end
rad_est = median(R);
% Generate unit circle
numcircpts = 500;
thetas = linspace(0,2*pi,numcircpts+1);
thetas = thetas(1:(end-1));
xs = cos(thetas); ys = sin(thetas);
% create convolution kernel
rad1 = rad_est*0.9;
boxrad = round(rad1*2);
boxres = ceil(2*boxrad+1); % size of img_test1
r0 = [0,0]+boxres/2+0.5; % center of img_test1
numcircpts = 100; % Number of angular coords
xs1 = round(rad1*xs+r0(1)); ys1 = round(rad1*ys+r0(2));
lininds1 = sub2ind(boxres*[1,1],ys1,xs1);
img_test1 = false(boxres);
img_test1(lininds1) = true;
img_test1 = imfill(img_test1,round([1,1]*boxres/2));
img_test1 = img_test1 * -1; %invert since it is negative down

bg = imopen(img_AFM,strel('disk',round(rad1*10)));
img_AFM2 = img_AFM - bg;
img_AFM2 = img_AFM;
convim1 = conv2(img_AFM2,img_test1); % Convolve first time
convim1 = wkeep(convim1,size(img_AFM)); % Trim down size
lminds = find_locmax(convim1,round(rad1),'none');
[ys,xs] = ind2sub(size(img_AFM),lminds);
porelocsC = [xs,ys];
bb = 20;
near_border = (porelocsC(:,1) < 1+bb) | (porelocsC(:,1) > aX-bb) ...
    |(porelocsC(:,2) < 1+bb) | (porelocsC(:,2) > aY-bb);
porelocsC = porelocsC(~near_border,:);
%% view Filter results
figure(1)
imagesc(img_AFM);
axis image
hold on
scatter(porelocsC(:,1),porelocsC(:,2),50,'+w')
hold off
porelocsC2 = filterByNN(porelocsC);
hold on
scatter(porelocsC2(:,1),porelocsC2(:,2),'or')
hold off
% init_porelocs = pore_locs;
% final_porelocs = porelocs1;
% figure(1); imagesc(img_AFM); axis image
% hold on
% scatter(init_porelocs(:,1),init_porelocs(:,2),50,'or')
% scatter(final_porelocs(:,1),final_porelocs(:,2),50,'+k')
% hold off
