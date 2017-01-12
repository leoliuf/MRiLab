function asCreateMultiRoiAnaCsv(asObjs, roiPos, combineCols, file, precision)
%asCreateMultiRoiAnaCsv(asObjs, roiPos, combineCols, file, precision)

if nargin < 5
    precision = '%f';
    if nargin < 4
        [fname, fpath] = uiputfile('.csv');
        file = [fpath, fname];

        if nargin < 3
            % mean and stdev in one column?
            combineCols = 1;

        end
    end
end

writeMSHeader = 0; %write header with text 'mean stdev'

% open file for writing
fid  = fopen(file,'wt');

% get roi names
roiNames = fieldnames(roiPos);

% write header
fprintf(fid,'title,ROI:\n');
fprintf(fid,','); % leave one cell for the title
for r = 1 : length(roiNames)
    % write roi names
    fprintf(fid,'%s,',roiNames{r});
    
    if ~combineCols
        fprintf(fid,','); % skip one col for stdev
    end
end
fprintf(fid,'\n'); % next line

if ~combineCols && writeMSHeader
    fprintf(fid,','); % leave one cell for the title
    for r = 1 : length(roiNames)
        % mean and stdev header
        fprintf(fid,'mean,stdev,');
    end
    fprintf(fid,'\n'); % next line
end





for a = 1 : length(asObjs)
    % for a = 1 : 1
    %     fprintf('processing asObj %d / %d\n',a,length(asObjs));
    fprintf('processing asObj %d / %d, ROI: ',a,length(asObjs));
    currObj = asObjs(a);
    
    % write title
    fprintf(fid,'%s,',currObj.getFigureTitle);
    
    for r = 1 : length(roiNames)
        fprintf('%d , ',r);
        
        % set roi to asObj
        currPos = getfield(roiPos,roiNames{r});
        currObj.createRoi(currPos);
% currObj.roi.addFilterString('<10000');        
        % get mean and stdev
        [m,s] = currObj.roi.getMeanAndStd;
        
        % write roi values to csv
        p = precision;        
        if combineCols
            str = [p, ' %c ', p,','];
            fprintf(fid,str,m,177,s);
%             fprintf(fid,'%2.1f %c %2.1f,',m,177,s);
        else
            str = [p, ',', p,','];
            fprintf(fid,str,m,s);
%             fprintf(fid,'%f,%f,',m,s);
        end
    end
    fprintf('\n');
    fprintf(fid,'\n'); % next line
    
end

fclose(fid);
fprintf('done\n');
end
