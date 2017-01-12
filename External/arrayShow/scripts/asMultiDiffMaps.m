function asMultiDiffMaps(diffObjs, minVal, maxVal)

if ~(isa(diffObjs,'arrShow'))
    error('first argument has to be an array of class arrShow');
end

if nargin < 3
    maxVal = Inf;
    if nargin < 2
        minVal = -Inf;
    end
end


NO = length(diffObjs);

if NO < 2
    error('need at least 2 arrShow objects');
end

refImg = diffObjs(1).getSelectedImages;
global asObjs

% create mask
mask = ones(size(refImg));
for i = 1 : NO
    currImg = diffObjs(i).getSelectedImages ;    
    mask(abs(currImg) == 0) = 0;
    mode = 'none';
    switch mode
        case 't2'
        mask(abs(currImg) >400) = 0;
        mask(abs(currImg) < 10 ) = 0;
        case 'r2'
        mask(abs(currImg) <1/400) = 0;
        mask(abs(currImg) > 1/10 ) = 0;        
        case 'none'
            mask = ones(size(mask));
    end
end

% limit refimage
refImg(refImg>maxVal)=maxVal;
refImg(refImg<minVal)=minVal;

for i = 1 : NO
    if diffObjs(i) ~= diffObjs(1)
        currImg = diffObjs(i).getSelectedImages ;

        % t2 cap all images
        currImg(currImg>maxVal)=maxVal;
        currImg(currImg<minVal)=minVal;


        h1 =  diffObjs(1).getFigureHandle();
        h2 =  diffObjs(i).getFigureHandle();
        t1 = diffObjs(1).getFigureTitle();
        t2 = diffObjs(i).getFigureTitle();
        tit = ['difference ',t2];

%         infoTxt = sprintf('Difference map:\nFig.%d - Fig.%d\n\nFigure Titles:\nFig.%d : %s\nFig.%d : %s\n',...
%             h1,h2, h1,t1, h2,t2);
        infoTxt = sprintf('Difference map:\nFig.%d (%s) - Fig.%d (%s)\n',...
            h2,t2, h1, t1);
        
        diffImg = currImg - refImg;


% diffImg = currImg./refImg;  % WAAARNINGGGG
% diffImg(isinf(diffImg)) = 1;

        diffImg = diffImg .* mask;

        if(1) % relative difference
            diffImg = diffImg * 100 ./ refImg;
            diffImg(isnan(diffImg)) = 0;
            diffImg(isinf(diffImg)) = 0;
        end
    %     newObj = arrShow2(diffImg, 'title',tit);
        as(diffImg, 'title',tit,'info',infoTxt);

    %     asObjs(end).window.setCW([ 172.1424 325.4843 ]);
    %     asObjs(end).window.setCW([ 0 200 ]);
    % refCW = diffObjs(i).window.getCW;
    % refCW(2) = refCW(2) / 16;
    refCW = [0,20];

    refPos = diffObjs(i).getFigureOuterPosition;
    refPos(2) = refPos(2) - refPos(4);
        asObjs(end).setFigureOuterPosition(refPos);
%         asObjs(end).complexSelect.setSelection('Abs')
        asObjs(end).complexSelect.setSelection('Re')
        asObjs(end).window.setCW(refCW);

    % netwObj.setMainWindowPosition(diffObjs(i).getMainWindowPosition);
    %     asObjs(end).setColormap('jet');
    end
end
% setAllAsObjsTitleToImageString;
end