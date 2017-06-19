function [ hLines , vLines ] = gridFromLocs( porelocs , nn_seprange )
%gridFromLocs Takes input porelocs along with accepted range for
%nearest-neighbor separations in order to calculate the horizontal and
%vertical gridlines that intially approximate it.
%   INPUT:  porelocs - [x,y] row vectors.
%           nn_seprange - [min_sep , max_sep] used the threshold nearest
%               neighbors from the rif-raf.
%   OUTPUT: hLines(vLines) - the sets of parallel lines that are close to
%               horizontal(vertical) to initialize the grid.
N = size(porelocs,1); % number of localizations
% Get displacements and expected nearest-neighbors distance range
dispmat = genDispmat( porelocs );
nnmu = mean(nn_seprange);
nnrange = nnmu-nn_seprange(1);
% Filter down to just nearest neighbors
nnBinary = abs(dispmat - nnmu) < nnrange;
numnn = sum(nnBinary);

% Calculating nearest-neighbor angles and distances for each point. Use
% average angle for each of the four points on a cross (r,l,u,d) to figure
% out the best angle estimates.
NNdists = zeros(4,N);
NNangs = zeros(4,N);
for k = 1:N % Loop over each pore localization
    centerpt = porelocs(k,:);
    ptslist = porelocs(find(nnBinary(:,k)),:);
    try % Try to find nearest neighbors with auto ptslist
        [NNdists(:,k),NNangs(:,k)] = getNNparams(centerpt,ptslist);
    catch ME % If multiple points were assigned to position, remove one
        if strcmp(ME.identifier,'pores:getNNparams:tooManyInPt')
            disp(['Iteration ', num2str(k)])
            tmpdisps = ptslist - repmat(centerpt,size(ptslist,1),1);
            tmpdisps = sum(tmpdisps.^2,2);
            ptslist((tmpdisps - nnmu) < nnrange/2 , :) = [];
            size(ptslist)
            try %try again
                [NNdists(:,k),NNangs(:,k)] = getNNparams(centerpt,ptslist);
                disp('Succeeded')
            catch ME2
                if strcmp(ME2.identifier,'pores:getNNparams:tooManyInPt')
                    NNdists(:,k) = NaN;
                    NNangs(:,k) = NaN;
                else
                    error(ME2)
                end
            end
            
        else
            error(ME)
        end
    end
end
NNang = nanmean(NNangs,2);

%% Calculating lines
% Calculate slope and intercept for first horizontal and vertical line
kk = find(numnn==4,1); % Use first pore with 4 nearest neighbors as point
Hslope = cot(-mean(NNang(1:2)));
Hint = ptslopeform(Hslope,porelocs(kk,:));
Vslope = cot(-mean(NNang(3:4)));
Vint = ptslopeform(Vslope,porelocs(kk,:));
% Use initial lines to calculate the full array of lines. Vertical lines
% are transposed, calculated, and transposed back to ease calculation.
hLines = calcParaLines([Hslope;Hint],porelocs);
vLines = calcParaLines(transLine([Vslope;Vint]),fliplr(porelocs));
vLines = transLine(vLines);
