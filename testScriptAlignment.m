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
afmfig = figure(1);
imagesc(AFM.Data1); axis image
hold on
scatter(AFM.porelocs(:,1),AFM.porelocs(:,2),50,'+r');
hold off
bffig = figure(2);
imagesc(BF.Data1); axis image
hold on
scatter(BF.porelocs(:,1),BF.porelocs(:,2),50,'+r');
hold off

%% AFM analysis
% Getting boxsize needs to be improved.
clocs = AFM.porelocs;
clocs = clocs(1:end-1,:); % drop last point for this sample
croprad = round(norm(clocs(1,:) - clocs(2,:))/2 - 1);
boxsize = 2*croprad + 1;
uls = max(1,round(clocs - croprad));
poreims = zeros(boxsize,boxsize,size(uls,1));
for k = 1:size(uls,1)
    try
        poreims(:,:,k) = croprect(AFM.Data1,[uls(k,:),boxsize*[1,1]]);
    catch
        poreims(:,:,k) = NaN;
    end
end

outbound = cell(1,size(poreims,3));
inbound = outbound;
Canny_sigma = sqrt(1);
for k = 1:size(poreims,3)
    [ outbound{k} , inbound{k} , dImag2{k} , BW{k} ] = genGradBounds(poreims(:,:,k),Canny_sigma);
    outbound{k} = outbound{k} + uls(k,:) - 1;
    inbound{k} = inbound{k} + uls(k,:) - 1;
end  
figure(afmfig);
hold on
lnwdth = 2;
for k = 1:numel(outbound)
    pts1 = outbound{k};
    pts2 = inbound{k};
    plot(pts1(:,1),pts1(:,2),'r','LineWidth',lnwdth)
    plot(pts2(:,1),pts2(:,2),'m','LineWidth',lnwdth)
end
clearvars pts1 pts2
hold off
%% Grid Alignment
activepts = ~isnan(sum(AFM.porelocs,2)) & ~isnan(sum(BF.porelocs,2));

afmlocs = AFM.porelocs(activepts,:);
bflocs = BF.porelocs(activepts,:);

% Three alignment methods
[ finalPs , tfParams , MSEs , theta_hats ] = alignGrids( bflocs , afmlocs );
tform = fitgeotrans(afmlocs([1,end],:),bflocs([1,end],:),'nonreflectivesimilarity');
[regParams,Bfit,ErrorStats]=absor(afmlocs',bflocs','doScale',true);

nout = outbound;
nin = inbound;
nout2 = nout;
nin2 = nin;
rotmat = @(ttt) [cos(ttt),-sin(ttt); sin(ttt),cos(ttt)];
% Using my fit
rr = rotmat(tfParams.phi);
x0 = tfParams.x0;
y0 = tfParams.y0;
c = tfParams.c;
% using results of fitgeotrans - Not yet working
% rr = tform.T(1:2,1:2);
% x0 = tform.T(3);
% y0 = tform.T(6);
% using results of absor function
% rr = regParams.R;
% x0 = regParams.t(1);
% y0 = regParams.t(2);
% c = regParams.s;

for k = 1:numel(nout)
    pts1 = outbound{k};
    pts2 = inbound{k};
    pts1 = (c*rr*pts1')';
    pts1(:,1) = pts1(:,1) + x0;
    pts1(:,2) = pts1(:,2) + y0;
    nout{k} = pts1;
    pts2 = (c*rr*pts2')';
    pts2(:,1) = pts2(:,1) + x0;
    pts2(:,2) = pts2(:,2) + y0;
    nin{k} = pts2;
    
%     tmp = outbound{k};
%     tmp(:,3) = 1;
%     tmp = tmp*tform.T;
%     nout2{k} = tmp(1:2,:);
%     tmp = inbound{k};
%     tmp(:,3) = 1;
%     tmp = tmp*tform.T;
%     nin2{k} = tmp(1:2,:);
end

figure(bffig);
hold on

for k = 1:numel(nout)
    plot(nout{k}(:,1),nout{k}(:,2),'r','LineWidth',lnwdth);
    plot(nin{k}(:,1),nin{k}(:,2),'m','LineWidth',lnwdth);
end
hold off
