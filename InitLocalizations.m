%% Load Data
ogPath = 'C:\Users\rib1.ADRICE\Documents\PoreAdsorbtion\RawData\AFM_images\';
PFXS = {'AFM','BF'};
delim = '_';
[FileName , PathName] = uigetfile('*.mat','Choose file',ogPath);
load([PathName,FileName]);

afmPore(Data1);