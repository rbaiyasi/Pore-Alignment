clearvars
afmPath = 'Z:\Files for Rashad\Correlated_AFM_BF_images';
bfPath = afmPath;
[afmFileName , PathName] = uigetfile('*.tif','Choose AFM image',afmPath);
if ~afmFileName
    error('No AFM selected');
end
img_afm = imread([PathName,afmFileName]);
img_afm = mean(img_afm,3);


[bfFileName , PathName] = uigetfile('*.tif','Choose BF image',bfPath);
if ~bfFileName
    error('No AFM selected');
end
img_bf = imread([PathName,bfFileName]);
img_bf = mean(img_bf,3);


figure(1)
setFont(16)
subplot(1,2,1)
imagesc(img_afm);
ax_afm = gca;
axis image
title('AFM')

subplot(1,2,2)
imagesc(img_bf);
ax_bf = gca;
axis image
title('BF')

porePicker(ax_afm)