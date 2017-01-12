%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)


classdef asIconClass

    properties (SetAccess = private, GetAccess = public)
        asBrowse        
        colorbar
        dontSend
        download
        lineup
        magnify
        pause
        play
        refresh
        rotLeft
        rotRight
        send
        squeeze
        upload
        wsObj       % assign workspace object        
    end
    
    methods (Access = public)
        function obj = asIconClass(iconPath)
                        
            % determine property names of this class
            iconNames = properties(mfilename);
            iconPaths = cellfun(@(x)[iconPath,filesep,x,'.png'],iconNames,...
                'UniformOutput',false);            
        
            % load pngs
            for i = 1 : length(iconNames)
                obj.(iconNames{i}) = iconRead(iconPaths{i});
            end
        end
    end        
end