function cPlot(x,y,varargin)
mode = 3;  % 1 = magnitude and phase,
           % 2 = real and imag
           % 3 = real and imag in one window
doHolding = false;
plotLegend = 0;
deleteInds = zeros(length(varargin),1);
parent = [];
if nargin == 1
    y = x;
    x = 1 : length(y);
end
if nargin > 2
    for i = 1 : floor(length(varargin)/2)
        option       = varargin{i*2-1};
        option_value = varargin{i*2};
        
        switch lower(option)
            case 'hold'
                doHolding  = option_value;
                deleteInds(i*2-1 : i*2) = [1;1];
            case 'mode'
                mode       = option_value;      
                deleteInds(i*2-1 : i*2) = [1;1];
            case 'parent'
                parent       = option_value;      
                deleteInds(i*2-1 : i*2) = [1;1];                
        end
    end
end
varargin(deleteInds ~= 0) = [];

if isempty(parent)
    parent = gca;
end

if doHolding
    hold on
end

switch mode
    case 1
        subplot(parent,2,1,1)
        plot(x,abs(y),varargin{:});
        title('abs');
        subplot(parent,2,1,2)
        plot(x,angle(y),varargin{:});
        title('phase');
    case 2
        subplot(parent,2,1,1)
        plot(x,real(y),varargin{:});
        title('real');
        subplot(parent,2,1,2)
        plot(x,imag(y),varargin{:});
        title('imag');
    case 3
        % put parent option at the end of varargin vector to allow for a
        % preceeding cursor style option (e.g. "x-");
        varargin = [varargin,{'parent'},{parent}];
        
        plot(x,[real(y),imag(y)],varargin{:});
        if plotLegend
            legend('real','imag');
        end
        
end
hold off
end
