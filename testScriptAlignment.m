%% Load in Data
ogPath = 'C:\Users\rib1.ADRICE\Documents\PoreAdsorbtion\RawData\AFM_images\';
PFXS = {'AFM','BF'};
delim = '_';
% choose afm file
[afmFileName , PathName] = uigetfile('AFM*analysis.mat','Choose file',ogPath);
% parse filename to get bf filename
filename = strsplit(afmFileName,delim);
filename = filename{end-1};
bfFileName = [PFXS{2},delim,filename,delim,'analysis'];
% Load data as structures
AFM = load([PathName,afmFileName]);
BF = load([PathName,bfFileName]);

%% 
figure(1)
imagesc(AFM.Data1); axis image
figure(2)
imagesc(BF.Data1); axis image
