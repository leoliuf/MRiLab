function [axesHandle, imageHandle] = imageCollage(...
    imgArr,...
    parentPanelH,...
    colorMap,...
    keepAspectRatio,...
    keepTrueSize)

% get size of the image array
[dimY, dimX, noFrames] = size(imgArr);

% delete all uiobjects from parentPanelH
oldHandles = get(parentPanelH,'Children');
if any(oldHandles)
    delete(oldHandles);
end

% units and window position
origUnits = get(parentPanelH,'Units');
set(parentPanelH,'Units','pixel');
fpos = get(parentPanelH,'position');
fWidth = fpos(3);
fHeight = fpos(4);

% width and height of every image
nCols = ceil(sqrt(noFrames));
nRows = ceil(noFrames / nCols);
colHeight = floor(fHeight/nRows);
colWidth  = floor(fWidth/nCols);

if keepAspectRatio % account for aspect ratio
    imgRatio = dimY / dimX;
    colHeight = colWidth * imgRatio;
    if colHeight > floor(fHeight/nRows)
        colHeight = floor(fHeight/nRows);
        colWidth = colHeight / imgRatio;
    end
    yBorder2 = floor((fHeight - nRows * colHeight)/2);
    xBorder2 = floor((fWidth - nCols * colWidth)/2);
else
    yBorder2 = 0;
    xBorder2 = 0;
end

% display
imageHandle = zeros(noFrames,1);
axesHandle  = zeros(noFrames,1);
for n=1:noFrames
    
    % image position
    x0 = mod((n-1),nCols)  * colWidth + xBorder2;
    y0 = fHeight - colHeight - (floor((n-1)/nCols) * colHeight) - yBorder2;
    
    ah = axes('Parent',parentPanelH,'units','pixel','position',[x0, y0, colWidth, colHeight],...
        'DrawMode','fast');
    
    if keepTrueSize
        pixelPos = get(ah,'position');
        set(ah,'position',[pixelPos(1:2), dimY, dimX]);
    end
    currImg = imgArr(:,:,n);
        
    if isreal(currImg)
        isComplex = false;
        colormap(ah,colorMap);
    else
        isComplex = true;
        [currImg, CLim] = complex2rgb(currImg, 256, [], colormap(ah, colorMap));
    end
    
    imageHandle(n) = imagesc(currImg,'Parent',ah);   
    axis(ah,'off');
    
    if keepAspectRatio
        set(ah,'DataAspectRatio',[1,1,1]);
    end
    
    if isComplex
        if (CLim(1) == CLim(2))
            CLim(1) = CLim(1)/2;
        end
        set(ah,'CLim',CLim);
    end    
    axesHandle(n) = ah;
end
set(parentPanelH,'Units',origUnits);
end