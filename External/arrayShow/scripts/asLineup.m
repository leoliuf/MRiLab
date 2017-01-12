function asLineup(allObjs, M, N, reorder)

if nargin == 0
    global asObjs;
    allObjs = asObjs;
end

if nargin < 4
    reorder = false;
    if nargin < 3
        
        if nargin == 2 && isscalar(allObjs)
            % allow a special call with only two given scalar arguments...
            % assume that we want to lineup global asObjs and treat
            % arguments as M and N
            N = M;
            M = allObjs;
            reorder = true;
            global asObjs;
            allObjs = asObjs;            
        
        
        else        
            N = 1;
            if nargin < 2
                M = 1;
                N = length(allObjs);
                if nargin < 1
                    reorder = true;
                end
            end          
        end
    end
end

NO = length(allObjs);

if reorder
    
    % sort in y direction
    allObjs = sortObjs(allObjs,2);
    
    % since y positions are given from bottom to top, invert array order
    allObjs = allObjs(end:-1:1);
    
    % sort N tupel in x direction
    for i = 1 : M
        rangeStart = (i-1) * N + 1;
        rangeStop = i * N;
        if rangeStop > NO
            rangeStop = NO;
        end
        range = rangeStart : rangeStop;
        allObjs(range) = sortObjs(allObjs(range),1);
    end
   
end

% pixel offsets for with and height
if ispc
ow = 0;
oh = 0;
else
    ow = 8;
    oh = 27;
end


refObj = allObjs(1);

% delete all duplicated copies of refObj from allObjs array
allObjs(allObjs == refObj) = [];
allObjs = [refObj, allObjs];
NO = length(allObjs);

refPos = refObj.getFigureOuterPosition;
l0 = refPos(1);
b0 = refPos(2);
w0 = refPos(3);
h0 = refPos(4);

if M == 1
    origScreenUnits = get(0,'Units');
    set(0,'Units','pixels');
    scrPos = get(0,'MonitorPositions');
    scrWidth = max(scrPos(:,3));
    scrWidth = scrWidth - l0;
    
    % automatically set M to to avoid leaving the screen horizontally    
    M = ceil(N * w0 / scrWidth);        
    N = floor(scrWidth / w0);
    
    set(0,'Units',origScreenUnits);
end
    
i = 1;
for m = 1 : M
    for n = 1 : N
        l = l0 + (n-1) * (w0 + ow);
        b = b0 - (m-1) * (h0 + oh);
        
        if allObjs(i) ~= refObj
            allObjs(i).setFigureOuterPosition([l, b, w0, h0]);
        end
        
        i = i + 1;
        if i > NO
            return;
        end
    end
end



end

function outObjs = sortObjs(inObjs, dir)
    % dir :  2 = y direction
%            1 = x direction

    NO = length(inObjs);
    dirPos = zeros(NO,1);
    for i = 1 : NO        
        pos = inObjs(i).getFigureOuterPosition;
        dirPos (i) = pos(dir);
    end
    [tmp,idx] = sort(dirPos);    
    outObjs = inObjs(idx);        
end

