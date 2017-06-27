function [ output_args ] = afmPore( dataOrAx , actionName , varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
TAGS = {'RedCircles','CurrentLocs','GridLines','GridPoints'};
%% Format inputs
if isgraphics(dataOrAx(1),'axes')
    ax1 = dataOrAx;
    fig1 = ax1.Parent;
    childs = allchild(ax1);
    imh = childs(find(isgraphics(childs,'Image'),1));
    Data1 = imh.CData;
elseif isnumeric(dataOrAx(1))
    Data1 = dataOrAx;
    fig1 = figure;
    ax1 = axes;
    imh = imagesc(Data1,'Parent',ax1);
    axis image
    setFont(14)
end
[Y,X] = size(Data1);
%% Main switch statement
switch actionName
    case 'hide'
        for l = 1:numel(varargin)
            tmphandles = findobj(allchild(ax1),'Tag',varargin{l});
            for k = 1:numel(tmphandles)
                tmphandles(k).Visible = 'off';
            end
        end
    case 'show'
        for l = 1:numel(varargin)
            tmphandles = findobj(allchild(ax1),'Tag',varargin{l});
            for k = 1:numel(tmphandles)
                tmphandles(k).Visible = 'on';
            end
        end
        
    case 'extract'
        tagnames = TAGS([2,4]);
        ss(1) = findobj(allchild(gca),'Tag',tagnames{1});
        ss(2) = findobj(allchild(gca),'Tag',tagnames{2});
        porelocs = [ss(1).XData;ss(1).YData]';
        assignin('base','porelocs',porelocs);
        if ~isempty(ss(2))
            gridlocs = [ss(2).XData;ss(2).YData]';
            assignin('base','gridlocs',gridlocs)
        end
    % find circles can take a varargin of pore size, or use porePicker to
    % get the value of the radius
    case 'findcircs'
        if isempty(varargin)
            rad_est = porePicker(ax1);
        else
            rad_est = varargin{1};
        end
        assignin('base','figrad',rad_est)
        rad_srch_rng = 5;
        disp(['Radius search for ',num2str(rad_est),' plus/minus ',num2str(rad_srch_rng)])
        [porelocs1, radii_afm, metric_afm] = imfindcircles(Data1,...
        round(rad_est + [-1,1]*rad_srch_rng),'ObjectPolarity','dark');
        N = size(porelocs1,1);
        % delete old objects
        vv = findobj(allchild(gca),'Tag',TAGS{1});
        ss = findobj(allchild(gca),'Tag',TAGS{2});
        delete(vv)
        delete(ss)
        % plot new points
        vv = viscircles(porelocs1,rad_est*ones(N,1)); %display with rad_est
        vv.Tag = TAGS{1};
        axes(ax1)
        hold on
        ss = scatter(ax1, porelocs1(:,1),porelocs1(:,2),50,'r+',...
            'LineWidth',1.5,'Tag',TAGS{2});
        hold off
        
    % Adds grid based on current pores
    case 'addgrid'
        ss = findobj(allchild(gca),'Tag',TAGS{2});
        porelocs1 = [ss.XData;ss.YData]'; % get locs from figure
        nn_seprange = getNNseprange(porelocs1,varargin{:});
        [Hlines , Vlines] = gridFromLocs( porelocs1 , nn_seprange );
        gridpts = calcGridIntersections(Hlines,Vlines);
        % delete old grid lines
        gg = findobj(allchild(gca),'Tag',TAGS{3});
        ss2 = findobj(allchild(gca),'Tag',TAGS{4});
        delete(gg)
        delete(ss2)
        % plot new lines
        axes(ax1)
        hold on
        xxH = [1,X]; % Horizontal lines
        for k = 1:size(Hlines,2)
            yyH = Hlines(1,k)*xxH + Hlines(2,k);
            gg1 = plot(xxH,yyH,'--k');
            gg1.Tag = TAGS{3};
        end
        yyV = [1,Y]; % Vertical lines
        tVlines = transLine(Vlines); % transpose for ease of plotting
        for k = 1:size(Vlines,2)
            xxV = tVlines(1,k)*yyV + tVlines(2,k);
            gg2 = plot(xxV,yyV,'--k');
            gg2.Tag = TAGS{3};
        end
        ss2 = scatter(gridpts(:,1),gridpts(:,2),'+k','Tag',TAGS{4});
        hold off

end    