% bf_1 = imread([PathName,bfname]);
% bf_1 = mean(bf_1,3);
% 
% afm_1 = imread([PathName,afmname]);
% afm_1 = mean(afm_1,3);
% 
% lnwdth = 2;
% 
% fig = figure;
% subplot(1,2,1)
% imagesc(bf_1); axis image
% ax_bf = gca;
% bfrect = [bful,bflr-bful+1];
% rectangle('Position',bfrect,'Linestyle','--','EdgeColor','w','LineWidth',lnwdth);
% 
% 
% subplot(1,2,2)
% imagesc(afm_1); axis image
% ax_afm = gca;
% afmrect = [afmul,afmlr-afmul+1];
% rectangle('Position',afmrect,'Linestyle','--','EdgeColor','w','LineWidth',lnwdth);

ogPath = 'C:\Users\rib1.ADRICE\Documents\PoreAdsorbtion\RawData\AFM_images\';
PFXS = {'AFM','BF'};
delim1 = '_';
[FileName , PathName] = uigetfile('AFM*.mat','Choose file',ogPath);
parsestr = strsplit(FileName,delim1);
filetype = parsestr{1};
filename = parsestr{2};
% filename = filename(1:end-4);
% Get AFM images
AFM = load([PathName,FileName]);
% Get BF images
BF = load([PathName,PFXS{2},delim1,filename,delim1,'analysis']);

imgs.AFM = AFM;
imgs.BF = BF;

figure(523)
for k = 1:numel(PFXS)
    pfx = PFXS{k};
    subplot(1,2,k)
    imagesc(imgs.(pfx).Data0);
    axis image
    tmprect = [imgs.(pfx).ul,imgs.(pfx).lr-imgs.(pfx).ul + 1];
    rectangle('Position',tmprect,'EdgeColor','w');
    plotlocs = imgs.(pfx).porelocs + imgs.(pfx).ul - 1;
    hold on
    scatter(plotlocs(:,1),plotlocs(:,2),50,'+r')
    hold off
end
