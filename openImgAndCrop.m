ogPath = 'Z:\Files for Rashad\Correlated_AFM_BF_images\';
savepath = 'C:\Users\rib1.ADRICE\Documents\PoreAdsorbtion\RawData\AFM_images\';
PFXS = {'AFM','BF'};
vars2save = {'ul','lr','filename','Data1','Data0','PFXS'};
PathName = [ogPath,'\'];
% [FileName , PathName] = uigetfile('AFM*.tif','Choose AFM image',ogPath);
[FileName , PathName] = uigetfile('AFM*.jpg','Choose AFM image',ogPath);
if ~FileName
    error('No Image selected');
end
delim1 = '_';
delim2 = '.';
parsestr = strsplit(FileName,delim1);
filetype = parsestr{1};
filename = strjoin(parsestr(2:end),delim1);
filename = filename(1:end-4);
tmpimg = imread([PathName,FileName]);
tmpimg = mean(tmpimg,3); %mean
tmpimg = flipud(tmpimg); % flip
tmpimg = tmpimg'; %transpose
tmpimg = flipud(tmpimg); % flip
img.AFM = tmpimg;
tmpimg = imread([PathName,PFXS{2},delim1,filename,'.tif']);
img.BF = mean(tmpimg,3);

figure(1)
subplot(1,2,1)
imagesc(img.AFM); axis image
ax.AFM = gca;
subplot(1,2,2)
imagesc(img.BF); axis image
ax.BF = gca;

for k = 1:numel(PFXS)
    Data0 = img.(PFXS{k});
    if strcmp(PFXS{k},'AFM') % Need to downsample afm at this point
        Data0(:,2:2:end) = [];
        Data0(2:2:end,:) = [];
    end
    fig = cropPreviewGUI(Data0);
    uiwait(fig);
    [Data1,ul,lr] = crop(Data0,ul,lr);
    axes(ax.(PFXS{k}))
    rectpos = [ul,lr-ul+1];
    rectangle('Position',rectpos);
    savename = [PFXS{k},delim1,filename,delim1,'analysis'];
    [savename,savepath] = uiputfile('*.mat','Save as...',[savepath,savename]);
    save([savepath,savename],vars2save{:});
end