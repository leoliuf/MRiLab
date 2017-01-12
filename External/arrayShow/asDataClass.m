%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)

classdef asDataClass < handle
    
    properties (GetAccess = public, SetAccess = private)
        dat         = [];   % the data dataArrayay
    end
    
    properties (Access = private)
        selection       = [];     % asSelectionClass object containing the valueChanger array
        
        updFig      = [];   % update figure callback from the main gui
        
        
        % allows methods to alter the image array, making it different
        % from the original that might still be in Workspace
        enableDestrFun  = true;
        
    end
    
    methods
        
        function enableDestructiveFunctions(obj, toggle)
            if nargin < 2
                toggle = true;
            else
                if ~isscalar (toggle)
                    warning('asDataClass:invalidArgument','invalid argument\n');
                end
            end
            obj.enableDestrFun = toggle;
        end
        
        function obj = asDataClass(dataArray, figureUpdateCallback)
            
            % validate input data
            obj.dat = asDataClass.validateImageArray(dataArray);
            
            % store figure update callback to local property
            obj.updFig = figureUpdateCallback;
            
        end
        
        function linkToSelectionClassObject(obj, selectionClassObject)
            obj.selection = selectionClassObject;
        end
        
        
        
        function fft2SelectedFrames(obj)
            if obj.enableDestrFun
                str = obj.selection.getValue;
                
                % create a command string from the gathered informations
                command = strcat('obj.dat(',str,') = asDataClass.mrFft(obj.dat(',str,'));');
                
                % execute command
                eval(command);
                
                obj.updFig();
            end
        end
        
        function ifft2SelectedFrames(obj)
            if obj.enableDestrFun
                str = obj.selection.getValue;
                
                % create a command string from the gathered informations
                command = strcat('obj.dat(',str,') = asDataClass.mrIfft(obj.dat(',str,'));');
                
                % execute command
                eval(command);
                
                obj.updFig();
            end
        end
        
        
        
        
        function fft2All(obj)
            if obj.enableDestrFun
                if numel(obj.dat) > 1e7
                    %                 mbh = waitbar(0,'deriving FFT of all
                    %                 images...','MenuBar','none');
                    mbh = msgbox('deriving FFT of all images...');
                    obj.dat = asDataClass.mrFft(obj.dat);
                    close(mbh);
                else
                    obj.dat = asDataClass.mrFft(obj.dat);
                end
                obj.updFig();
            end
        end
        
        function ifft2All(obj)
            if obj.enableDestrFun
                if numel(obj.dat) > 1e7
                    mbh = msgbox('deriving iFFT of all images...');
                    obj.dat = asDataClass.mrIfft(obj.dat);
                    close(mbh);
                else
                    obj.dat = asDataClass.mrIfft(obj.dat);
                end
                obj.updFig();
            end
        end
        
        function fftshift2All(obj)
            if obj.enableDestrFun
                if numel(obj.dat) > 1e7
                    %                 mbh = waitbar(0,'deriving FFT of all
                    %                 images...','MenuBar','none');
                    mbh = msgbox('deriving FFTshift2 of all images...');
                    obj.dat = asDataClass.fftshift2(obj.dat);
                    close(mbh);
                else
                    obj.dat = asDataClass.fftshift2(obj.dat);
                end
                obj.updFig();
            end
        end
        
        
        function rot90(obj, k)
            if obj.enableDestrFun
                if nargin < 2
                    k = 1;
                else
                    if k ~= 1 && k ~=-1
                        warning('arrShow:rot90','k can be either -1 or 1');
                        k = 1;
                    end
                end
                
                si = size(obj.dat);
                noDims = length(si);
                
                % get original selection
                origSel = obj.selection.getValueAsCell;
                
                % get colon dims
                colDims = obj.selection.getColonDims;
                
                if any(colDims == 0)
                    warning('arrShow:rot90','both colon dimensions need to be selected for rot90');
                else
                    colDims = sort(colDims);
                    pOrder = 1 : noDims;  % original panel ordering
                    
                    newOrder = pOrder;
                    newSel = origSel;
                    
                    newOrder(colDims(1)) = pOrder(colDims(2));
                    newOrder(colDims(2)) = pOrder(colDims(1));
                    newSel{colDims(1)} = origSel{colDims(2)};
                    newSel{colDims(2)} = origSel{colDims(1)};
                    
                    obj.dat = permute(obj.dat,newOrder);
                    if k == 1
                        obj.dat = flipdim(obj.dat,colDims(1));
                    else
                        obj.dat = flipdim(obj.dat,colDims(2));
                    end
                    
                    
                    % valueChanger array
                    newDims = size(obj.dat);
                    obj.selection.reInit(newDims, newSel);
                    
                    obj.updFig();
                end
            end
        end
        
        function flipDim(obj,dim)
            if obj.enableDestrFun
                obj.dat = flipdim(obj.dat,dim);
                obj.updFig();
            end
        end
        
        function sumSqr(obj,dim)
            if obj.enableDestrFun
                if nargin ==1
                    dim = length(size(obj.dat)); % use the last dimensions
                end
                si = size(obj.dat);
                l = length(si);
                if dim > l
                    fprintf('dimension %d > number of available dimensions (%d)\n',dim, l);
                else
                    obj.dat = sqrt(sum(obj.dat .* conj(obj.dat),dim));
                    
                    % get original selection
                    si(dim) = 1;
                    sel = obj.selection.getValueAsCell;
                    sel{dim} = '1';
                    
                    
                    % update selection class
                    obj.selection.reInit(si, sel);
                    
                    obj.updFig();
                end
            end
        end
        
        function max(obj,dim)
            obj.maxMin(dim,@max);
        end
        
        function min(obj,dim)
            obj.maxMin(dim,@min);
        end
        
        
        function squeeze(obj)
            if obj.enableDestrFun
                % get original selection
                sel = obj.selection.getValueAsCell;
                si = size(obj.dat);
                
                if length(sel) > 2
                    % find dims which will be kept alive
                    sd = si ~= 1;
                    
                    obj.dat = squeeze(obj.dat);
                    sel = sel(sd);
                    
                    % avoid dealing with less than 2 dimensions
                    if length(sel) == 1
                        sel = [sel,{'1'}];
                    end
                    
                    
                    obj.selection.reInit( size(obj.dat), sel);
                    
                    obj.updFig();
                else
                    fprintf('squeezing away one of the last 2 dimensions is not implemented yet :-(\n');
                end
            end
        end
        
        
        function setDestructiveSelectionString(obj)
            A = obj.dat;
            
            noDims = length(size(A));
            colonStr = repmat(': , ',[1,noDims]);
            initStr = ['A = A( ',colonStr,';'];
            initStr(end-2) = ')';
            
            str = mydlg('Enter selection','Set selection string',initStr);
            if isempty(str)
                return;
            end
            
            try
                eval(str);
            catch err
                disp(err);
                return;
            end
            
            obj.overwriteImageArray(A);
        end
        
        function permute(obj,order)
            if obj.enableDestrFun
                
                % if no reordering vector is given: open permute dialog
                if nargin < 2 || isempty(order)
                    noDims = length(size(obj.dat));
                    prevValue = num2str(1:noDims,'%d,');
                    prevValue(end) = []; % remove last ','
                    newValue = mydlg('Enter selection string','Selection input dlg',prevValue);
                    if ~isempty(newValue)
                        order = str2num(newValue); % need to use str2num instead of str2double as this is not a scalar
                        if (length(order) ~= noDims ||...
                                min(order) ~= 1 ||...
                                max(order) ~= noDims)
                            warning('PermuteDlg:valueCheck','invalid value');
                            return;
                        end
                    else
                        return;
                    end
                end
                
                % get original selection
                sel = obj.selection.getValueAsCell;
                
                % permute array and selection
                obj.dat = permute(obj.dat,order);
                sel = sel(order);
                
                si = size(obj.dat);
                obj.selection.reInit( si, sel);
                obj.updFig();
            end
        end
        
        
        function overwriteImageArray(obj, arr)
            if obj.enableDestrFun
                
                % get original selection
                origSel = obj.selection.getValueAsCell;
                origSi = size(obj.dat);
                
                % accept new array
                obj.dat = asDataClass.validateImageArray(arr);
                newSi = size(obj.dat);
                
                % check if dimensions are equal
                if length(newSi) == length(origSi)
                    dimEqual = true;
                    for i = 1 : length(newSi)
                        if(origSi(i) ~= newSi(i))
                            dimEqual = true;
                            break;
                        end
                    end
                else
                    dimEqual = false;
                end
                
                % create init selection cell array
                if dimEqual
                    sel = origSel;
                else
                    sel = cell(length(newSi),1);
                    sel{1} = ':';
                    sel{2} = ':';
                    for i = 3 : length(newSi)
                        sel{i} = '1';
                    end
                end
                
                % reinit selection class
                obj.selection.reInit(newSi, sel);
                
                obj.updFig();
            end
            
        end
    end
    
    
    
    methods (Static)
        
        function dataArray = validateImageArray(dataArray)
            if iscell(dataArray)
                dataArray = asDataClass.cell2imageMat(dataArray);
            end
            
            if ~isnumeric(dataArray)
                warning('asDataClass:validateImageArray','Input dataArrayay seems not to be numeric. Trying to convert it into double...');
                dataArray = double(dataArray);
            end
            
            si      = size(dataArray);
            if length(si) < 2
                error('asDataClass:validateImageArray','input dataArrayay has to be at least 2 dimensional');
            end
            
            if issparse(dataArray);
                dataArray = full(dataArray);
            end
            
            if any(~isnumeric(dataArray(:)))
                warning('asDataClass:validateImageArray','There are invalid entries in the image dataArrayay. Replacing these entries with zeros...');
                dataArray(~isnumeric(dataArray(:))) = 0;
            end
        end
        
        function arr = cell2imageMat(cellArr)
            
            fprintf('isolating images from input cell vector...');
            
            % check if first cell content has at least 2 dimensions
            refSi = size(cellArr{1});
            if length(refSi) >= 2
                refN = prod(refSi);
            else
                error('asDataClass:cell2imageMat','arrays in input cell must be at least 2 dimensional');
            end
            
            % if all other cells contain arrays with same number of
            % elements, sort them into an image array
            arr = zeros([refN,numel(cellArr)]);
            for i = 1 : numel(cellArr)
                if numel(cellArr{i}) == refN
                    arr(:,i) = cellArr{i}(:);
                else
                    error('asDataClass:cell2imageMat','arrays in input cell have different size');
                end
            end
            si  = [refSi, squeeze(size(cellArr))];
            arr = reshape(arr,si);
            fprintf('  done.\n');
        end
        
        function out = fftshift2(in)
            out = fftshift(fftshift(in,1),2);
        end     
        
        %------------------------------------------------------------------
        %Change mrFft & mrIfft for MRiLab compatibility <Fang Liu>
        %28-April-2013  change fft2 to fftn
        %16-May-2013    apply different fft & ifft based on input dimension for multi Rx coil recon

%         function out = mrFft(in)
%             si = size(in);
%             a = 1 / (sqrt(si(1)) * sqrt(si(2)));
%             out = asDataClass.fftshift2(fft2(asDataClass.fftshift2(in))) * a;
%             
%         end
%         
%         function out = mrIfft(in)
%             si = size(in);
%             a = sqrt(si(1)) * sqrt(si(2));
%             out = asDataClass.fftshift2(ifft2(asDataClass.fftshift2(in))) * a;
%         end
        
        function out = mrFft(in)
            switch ndims(in)
                case 5 % multi echo
                    d = size(in);
                    out = zeros(d);
                    for j = 1: d(5)
                        for i = 1: d(4)
                            out(:,:,:,i,j) = fftshift(fftn(fftshift(in(:,:,:,i,j))));
                        end
                    end
                case 4 % multi Rx coil
                    d = size(in);
                    out = zeros(d);
                    for i = 1: d(4)
                        out(:,:,:,i) = fftshift(fftn(fftshift(in(:,:,:,i))));
                    end
                otherwise % normal
                    out = fftshift(fftn(fftshift(in)));
            end
        end
        
        function out = mrIfft(in)
           switch ndims(in)
                case 5 % multi echo
                    d = size(in);
                    out = zeros(d);
                    for j = 1: d(5)
                        for i = 1: d(4)
                            out(:,:,:,i,j) = fftshift(ifftn(fftshift(in(:,:,:,i,j))));
                        end
                    end
                case 4 % multi Rx coil
                    d = size(in);
                    out = zeros(d);
                    for i = 1: d(4)
                        out(:,:,:,i) = fftshift(ifftn(fftshift(in(:,:,:,i))));
                    end
                otherwise % normal
                    out = fftshift(ifftn(fftshift(in)));
            end
        end
        %-----------------End----------------------------------------------
        
    end
    
    methods (Access = private)
        function maxMin(obj,dim,funPtr)
            if obj.enableDestrFun
                if nargin ==1
                    dim = length(size(obj.dat)); % use the last dimensions
                end
                si = size(obj.dat);
                l = length(si);
                if dim > l
                    fprintf('dimension %d > number of available dimensions (%d)\n',dim, l);
                else
                    obj.dat = funPtr(obj.dat,[],dim);
                    
                    % get original selection
                    si(dim) = 1;
                    sel = obj.selection.getValueAsCell;
                    sel{dim} = '1';
                    
                    
                    % update selection class
                    obj.selection.reInit(si, sel);
                    
                    obj.updFig();
                end
            end
        end
    end
end



