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


[aY,aX] = size(img_AFM);
%% get porelocs1
[ pore_locs , nn_seprange , CC] = afmPoreDetect( img_AFM );
[porelocs1 , filterParams] = filterByNN(pore_locs);

%% get porelocs2 using convolution


%% view Filter results
init_porelocs = pore_locs;
final_porelocs = porelocs1;
figure(1); imagesc(img_AFM); axis image
hold on
scatter(init_porelocs(:,1),init_porelocs(:,2),50,'or')
scatter(final_porelocs(:,1),final_porelocs(:,2),50,'+k')
hold off