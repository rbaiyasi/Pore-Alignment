%% testScript 
%% Load Data - optional choice between large or small pores
% Pore size is manually input here - this will probably be the last step
clearvars
load BF_area14_crop
init_rad = 19;

load small_pores1_crop
init_rad = 10;

%% Determine inital pore localizations through bfPoreDetect
[Y,X] = size(bf);
[ porelocs , nn_seprange ] = bfPoreDetect(bf,init_rad);

% Figure for visualization of the points
figure(1)
imagesc(bf); axis image
setFont(20)
axis off
tmpnums = 1:size(porelocs,1);
tmpnums = cellstr(num2str(tmpnums'));
hold on
scatter(porelocs(:,1),porelocs(:,2),50,'r');
text(porelocs(:,1),porelocs(:,2),tmpnums,'r');
hold off

%% Get initial grid lines from gridFromLocs, then get grid points
% Grid points are used to pick out regions of interest for refining pore
% localization in the next step.
[ hLines , vLines ] = gridFromLocs( porelocs , nn_seprange );
init_grid_pts = calcGridIntersections(hLines,hLines);

% Update Figure 1 for visualization
figure(1);
hold on
xxH = [1,X]; % Horizontal lines
for k = 1:size(hLines,2)
    yyH = hLines(1,k)*xxH + hLines(2,k);
    plot(xxH,yyH,'k');
end
yyV = [1,Y]; % Vertical lines
tvLines = transLine(vLines);
for k = 1:size(vLines,2)
    xxV = tvLines(1,k)*yyV + tvLines(2,k);
    plot(xxV,yyV,'k')
end
hold off


%% from grid intersections, get refined pore localizations