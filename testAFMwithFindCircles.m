% clearvars
% load allcroppedAFM
% 
% [Y,X,K] = size(AFMs);
% rad_est = NaN(1,K);
% centers = cell(1,K);
% radii = centers;
% metric = centers;
% for k = 1:5
%     tic
%     img_AFM = AFMs(:,:,k);
%     [ pore_locs , nn_seprange , CC] = afmPoreDetect( img_AFM );
% %     [porelocs1 , filterParams] = filterByNN(pore_locs);
%     %estimate radius
%     for l = 1:CC.NumObjects
%         [y,x] = ind2sub(CC.ImageSize,CC.PixelIdxList{l});
%         [xc,yc,tmpR] = circfit(x,y);
%         xy0(l,:) = [xc,yc];
%         R(l) = tmpR;
%     end
%     rad_est(k) = median(R);
%     [centers{k}, radii{k}, metric{k}] = imfindcircles(img_AFM,round(rad_est(k)*[0.5,1.5]),'Sensitivity',0.5,'ObjectPolarity','dark');
%     tmpt = toc;
%     disp(['Image ',num2str(k),'; runtime: ',num2str(tmpt)]);
%     
%     figure(k)
%     imagesc(img_AFM); axis image
%     viscircles(centers{k},radii{k},'EdgeColor','r');
% end

clearvars
afmPath = 'Z:\Files for Rashad\Correlated_AFM_BF_images';
bfPath = afmPath;
[FileName , PathName] = uigetfile('*.tif','Choose image',afmPath);
if ~FileName
    error('No AFM selected');
end
img = imread([PathName,FileName]);
img = mean(img,3);

porePicker(img)