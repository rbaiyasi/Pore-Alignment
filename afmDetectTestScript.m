%% Space to work out how to detect the brightfield pores.
afmPath = 'Z:\Files for Rashad\Correlated_AFM_BF_images';
[afmFileName , PathName] = uigetfile('AFM_*.tif','Choose AFM image',afmPath);
if ~afmFileName
    error('No AFM selected');
end
img_afm = imread([PathName,afmFileName]);
img_afm = mean(img_afm,3);
ul_afm = [104,73];
lr_afm = [1092,1096];
img_afm_crop = crop(img_afm,ul_afm,lr_afm);

fig1 = figure(1);
imh = imagesc(img_afm_crop); axis image off
ax1 = gca;
setFont(16)

% rh = imrect(ax1);
% set(fig1,'KeyPressFcn',@continueOnReturn);

% rad_est = 18; %1
% rad_est = 28; %2
% rad_est = 30; %3
% rad_est = 34; %4 FAIL
% rad_est = 35; %5 FAIL
% rad_est = 38; %6 FAIL
% rad_est = 38; %7 FAIL
% rad_est = 36; %8 FAIL
% rad_est = 29; %9 FAIL
% rad_est = 19; %10 FAIL
% rad_est = 13; %11 FAIL
% rad_est = 14; %12
% rad_est = 29; %13
% rad_est = 37; %14
% rad_est = 39; %15 FAIL
% rad_est = 25; %16
rad_est = porePicker(ax1)
I2 = img_afm_crop;
% I2 = imtophat(img_afm_crop,strel('disk',round(rad_est*3)));
[afmporelocs1, radii_afm, metric_afm] = imfindcircles(I2,...
    round(rad_est + [-1,1]*8),'ObjectPolarity','dark');
porelocs1 = afmporelocs1;
N = size(porelocs1,1);
figure(1)
viscircles(porelocs1,rad_est*ones(N,1));
