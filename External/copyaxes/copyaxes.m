function copyaxes(source, destination, varargin)
% 
% COPYAXES - copy a handle object axes inpt
% 
% COPYAXES(SOURCE, DESTINATION) - copy axes from SOURCE to DESTINATION
% 
% COPYAXES(..., isInSubplot) - if the destination is in a subplot figure
%       (default false).
% 
% COPYAXES(..., isLegend) - if the axes is a legend (only if isInSubplot is
%       true) (default false)
% 
% 
% EXAMPLE: Copy a axes with plot
% 
%   plot([1:0.1:2*pi], sin([1:0.1:2*pi]));
%   title('sin function')
%   xlabel('x')
%   ylabel('sin(x)')
%   ax = gca;
% 
%   figure;
%   ax_new = axes;
%   copyaxes(ax, ax_new)
% 
% 
% EXAMPLE: Copy a axes with bar
% 
%   bar(rand(10,5),'stacked');
%   title('bar stacket function')
%   xlabel('x label')
%   ylabel('y label')
%   ax = gca;
% 
%   figure;
%   ax_new = axes;
%   copyaxes(ax, ax_new)
% 
% 
% EXAMPLE: Copy a axes and legend (the legend is an axes object)
% 
%   plot([1:0.1:2*pi], sin([1:0.1:2*pi]));
%   title('sin function')
%   xlabel('x')
%   ylabel('sin(x)')
%   lg = legend('sin');
%   ax = gca;
% 
%   figure;
%   ax_new = axes;
%   lg_new = axes;
%   copyaxes(ax, ax_new)
%   copyaxes(lg, lg_new)
% 
% EXAMPLE: Copy an axes with a surface in a subplot. 
%   Colormap is a figure property, not axes property.
% 
%   k = 5;
%   n = 2^k-1;
%   [x,y,z] = sphere(n);
%   c = hadamard(2^k);
%   surf(x,y,z,c);
%   axis equal
%   title('sphere')
%   xlabel('x label')
%   ylabel('y label')
%   zlabel('z label')
%   ax = gca;
%   colormap([1  1  0; 0  1  1])
% 
%   figure;
%   ax_new = subplot(2,2,1);
%   copyaxes(ax, ax_new, true)
%   colormap([1  1  0; 0  1  1])
%  
% EXAMPLE:  Copy a surface in a subplot
% 
%   [x,y] = meshgrid([-2:.4:2]);
%   Z = x.*exp(-x.^2-y.^2);
%   fh = figure('Position',[350 275 400 300],'Color','w');
%   ax = subplot(1,2,1);
%     set(ax, 'Color',[.8 .8 .8],'XTick',[-2 -1 0 1 2],...
%           'YTick',[-2 -1 0 1 2]);
%   sh = surface('XData',x,'YData',y,'ZData',Z,...
%              'FaceColor',get(ax,'Color')+.1,...
%              'EdgeColor','k','Marker','o',...
%              'MarkerFaceColor',[.5 1 .85]);
%   view(3)
% 
%   ax_new = subplot(1,2,2);
%   copyaxes(ax, ax_new, true)
%  
% EXAMPLE:  Copy an hist in a subplot
%  
%     x = -4:0.1:4;
%     y = randn(500,1);
%     figure;
%     ax = subplot(1,2,1);
%     hist(y,x) 
% 
%     ax_new = subplot(1,2,2);
%     copyaxes(ax, ax_new, true)
% 
% 
% EXAMPLE:  Copy an pie in a subplot
%  
%     x = [1 3 0.5 2.5 2];
%     explode = [0 1 0 0 0];
%     figure;
%     colormap jet
%     ax =  subplot(1,2,1);
%     pie(x,explode)
% 
%     ax_new = subplot(1,2,2);
%     copyaxes(ax, ax_new, true)
%      
% 
% EXAMPLE:  Copy an figure in a subplot
% 
%     load earth
%     figure
%     ax = subplot(1,2,1);
%     image(X); colormap(map)
% 
%     ax_new = subplot(1,2,2);
%     copyaxes(ax, ax_new, true)
% 
% 
% tags: figure, copy, axes, line, pie, bar, hist, surface, 
% 
% 
% author: Mar Callau-Zori
% PhD student - Universidad Politecnica de Madrid
% 
% version: 1.2, December 2011
% 

    isInSubplot = false;
    isLegend    = false;        
    
    if nargin>2
        switch nargin

            case 3
                isInSubplot = varargin{1};
            case 4
                isInSubplot = varargin{1};
                isLegend    = varargin{2};            
            otherwise
                error('ERROR:copyaxes:argChk', 'Wrong input arguments');
        end
    end

    if ~isLegend
        copyobj(get(source, 'Children'), destination);

        title = copyobj(get(source, 'Title'), destination);
        set(destination, 'Title', title);

        xlabel = copyobj(get(source, 'XLabel'), destination);
        set(destination, 'XLabel', xlabel);

        ylabel = copyobj(get(source, 'YLabel'), destination);
        set(destination, 'YLabel', ylabel);

        zlabel = copyobj(get(source, 'ZLabel'), destination);
        set(destination, 'ZLabel', zlabel);
    else
        set(destination, 'string', get(source, 'string'))
    end
    
    properties_str = {  'Units'
                        'ActivePositionProperty'
                        'ALim'
                        'ALimMode'
                        'AmbientLightColor'
                        'Box'
                        'CameraPosition'
                        'CameraPositionMode'
                        'CameraTarget'
                        'CameraTargetMode'
                        'CameraUpVector'
                        'CameraUpVectorMode'
                        'CameraViewAngle'
                        'CameraViewAngleMode'
                        'CLim'
                        'CLimMode'
                        'Color'
                        'CurrentPoint'
                        'ColorOrder'
                        'DataAspectRatio'
                        'DataAspectRatioMode'
                        'DrawMode'
                        'FontAngle'
                        'FontName'
                        'FontSize'
                        'FontUnits'
                        'FontWeight'
                        'GridLineStyle'
                        'Layer'
                        'LineStyleOrder'
                        'LineWidth'
                        'MinorGridLineStyle'
                        'NextPlot'
                        'OuterPosition'
                        'PlotBoxAspectRatio'
                        'PlotBoxAspectRatioMode'
                        'Projection'
                        'Position'
                        'TickLength'
                        'TickDir'
                        'TickDirMode'
                        'TightInset'
                        'View'
                        'XColor'
                        'XDir'
                        'XGrid'
                        'XAxisLocation'
                        'XLim'
                        'XLimMode'
                        'XMinorGrid'
                        'XMinorTick'
                        'XScale'
                        'XTick'
                        'XTickLabel'
                        'XTickLabelMode'
                        'XTickMode'
                        'YColor'
                        'YDir'
                        'YGrid'
                        'YAxisLocation'
                        'YLim'
                        'YLimMode'
                        'YMinorGrid'
                        'YMinorTick'
                        'YScale'
                        'YTick'
                        'YTickLabel'
                        'YTickLabelMode'
                        'YTickMode'
                        'ZColor'
                        'ZDir'
                        'ZGrid'
                        'ZLim'
                        'ZLimMode'
                        'ZMinorGrid'
                        'ZMinorTick'
                        'ZScale'
                        'ZTick'
                        'ZTickLabel'
                        'ZTickLabelMode'
                        'ZTickMode'
                        'BeingDeleted'
                        'ButtonDownFc'
                        'Clipping'
                        'CreateFcn'
                        'DeleteFcn'
                        'BusyAction'
                        'HandleVisibility'
                        'HitTest'
                        'Interruptible'
                        'Selected'
                        'SelectionHighlight'
                        'Tag'
                        'Type'
                        'UIContextMenu'
                        'UserData'
                        'Visible'};


    for i=1:length(properties_str)
        
        if (strcmpi(properties_str{i}, 'position') || strcmpi(properties_str{i}, 'outerposition'))
            
            if ~isInSubplot 
                try
                    set(destination, properties_str{i}, get(source, properties_str{i}));
                catch e
                    if ~strcmpi(e.identifier, 'MATLAB:hg:propswch:FindObjFailed') && ...
                       ~strcmpi(e.identifier, 'MATLAB:hg:g_object:MustBeInSameFigure')
                            rethrow(e);
                    end
                end
                
            elseif isLegend
                % change the reference  
                    try
                        units_dst = get(destination, 'units');
                        units_src = get(source, 'units');
                        set(destination, 'units', 'pixels');
                        set(source, 'units', 'pixels');
                        aux_dst = get(destination, properties_str{i});
                        aux_src = get(source, properties_str{i});
                        aux_dst(3) =  aux_src(3);
                        aux_dst(4) =  aux_src(4);
                        set(destination, properties_str{i}, aux_dst);
                        set(destination, 'units', units_dst);
                        set(source, 'units', units_src);
                    catch e
                        if ~strcmpi(e.identifier, 'MATLAB:hg:propswch:FindObjFailed') && ...
                           ~strcmpi(e.identifier, 'MATLAB:hg:g_object:MustBeInSameFigure')
                                rethrow(e);
                        end
                    end
            end
        else
            try
                set(destination, properties_str{i}, get(source, properties_str{i}));
            catch e
                if ~strcmpi(e.identifier, 'MATLAB:hg:propswch:FindObjFailed') && ...
                   ~strcmpi(e.identifier, 'MATLAB:hg:g_object:MustBeInSameFigure')
                         rethrow(e);
                end
            end
        end
    end
 
end




