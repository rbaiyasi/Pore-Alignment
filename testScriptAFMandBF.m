clearvars
afmPath = 'Z:\Files for Rashad\Correlated_AFM_BF_images';
bfPath = afmPath;
PathName = [afmPath,'\'];
afmFileName = 'AFM_area1.tif';
% bfFileName = 'Bf_area1.tif';
[afmFileName , PathName] = uigetfile('*.tif','Choose AFM image',afmPath);

if ~afmFileName
    error('No AFM selected');
end
img_afm = imread([PathName,afmFileName]);
img_afm = mean(img_afm,3);
ul_afm = [69,73];
lr_afm = [1092,1096];
img_afm = crop(img_afm,ul_afm,lr_afm);

[bfFileName , PathName] = uigetfile('*.tif','Choose BF image',bfPath);
if ~bfFileName
    error('No AFM selected');
end
img_bf = imread([PathName,bfFileName]);
img_bf = mean(img_bf,3);
ul_bf = [141,210];
lr_bf = [657,861];
img_bf = crop(img_bf,ul_bf,lr_bf);

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
%% get AFM initial pores
Rs = porePicker(ax_afm);
rad_est_afm = Rs;
[afmporelocs1, radii_afm, metric_afm] = imfindcircles(img_afm,...
    round(rad_est_afm + [-1,1]*5),'ObjectPolarity','dark');
hold on
s_afm = scatter(afmporelocs1(:,1),afmporelocs1(:,2),'+r','Parent',ax_afm);
hold off

%% get BF initial pores
Rs = porePicker(ax_bf);
radfact = 1.0;
rad_est_bf = Rs * radfact;
[ bfporelocs1 , nn_seprange ] = bfPoreDetect( img_bf , (rad_est_bf) );
N_bf = size(bfporelocs1,1);
hold on
s_bf = scatter(bfporelocs1(:,1),bfporelocs1(:,2),'+r','Parent',ax_bf);
axes(ax_bf)
viscircles(bfporelocs1,rad_est_bf*ones(N_bf,1),'EdgeColor','r');
hold off