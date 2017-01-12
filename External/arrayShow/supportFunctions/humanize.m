classdef humanize
    % humanize functions
    % collection of static functions to convert si units into 'human readable'
    % strings. Currently implemented functions are
    %
    % humanize.seconds      % creates a time string
    % humanize.bytes        % creates a data size string
    % humanize.clock
    %
    % written by T.Sumpf (tsumpf@gwdg.de) June 2010
    
    methods (Static)
        function str = bytes(nBytes, precision)
            if nargin < 2
                precision = '%1.3f';
            end
            order = log2(nBytes);
            order = floor(order/10) * 10;
            
            unitValue = nBytes / 2^order;
            
            switch(order)
                case 0
                    str = [num2str(nBytes),' byte'];
                case 10
                    str = [num2str(unitValue,precision),' kB'];
                case 20
                    str = [num2str(unitValue,precision),' MB'];
                case 30
                    str = [num2str(unitValue,precision),' GB'];
                otherwise
                    str = [num2str( nBytes / 2^40,precision),' TB'];
            end
            
            
            
        end
        
        function str = seconds(secs, precision)
            if nargin < 2
                precision = '%1.3f';
            end
            
            % decimal system
            if secs < 1e-3
                str = [num2str(secs*1e6,precision),' us'];
                return
            end
            
            if secs < 1
                str = [num2str(secs*1e3,precision),' ms'];
                return
            end
            
            if secs < 60
                str = [num2str(secs,precision),'s'];
                return
            end
            
            
            
            % ...else
            % "date system"
            
            remSecs = floor(mod(secs,60));
            mins    = mod(floor(secs/60),60);
            hours   = mod(floor(secs/(60*60)),24);
            days    = floor(secs/(60*60*24));
            
            
            
            
            str = [num2str(remSecs),'s'];
            
            if secs >= 60
                str = [num2str(mins),'min : ',str];
            end
            
            if secs >= (60 * 60)
                str = [num2str(hours),'h : ',str];
            end
            
            if secs >= (60 * 60 * 24)
                str = [num2str(days),'d : ',str];
            end
            
        end
        
        
        function str = clock(clk, date_time_or_both)
            if nargin < 1
                date_time_or_both = 'both';
            end
            
            c = fix(clk);
            
            d = sprintf('%d.%d.%d',c(3),c(2),c(1));
            t = sprintf('%d:%d:%d',c(4),c(5),c(6));
            
            switch lower(date_time_or_both)
                case 'date'
                    str = d;
                case 'time'
                    str = t;
                case 'both'
                    str = [d, ' ' , t];
            end
            
            
        end
    end
end