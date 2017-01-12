
function [Ext,ExtTime]=ExtBit(p)
%create a Ext signal pulse starting from tStart
%tStart Ext signal start time
%Ext Ext flag
global VCtl;

tStart=p.tStart;
Ext=p.Ext;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

[Ext,ExtTime]=StdBit(tStart,tStart+2*VCtl.MinUpdRate,Ext); % Ext

% Create Duplicates
if Duplicates~=1 & DupSpacing ~=0
    Ext=repmat(Ext,[1 Duplicates]);
    TimeOffset = repmat(0:DupSpacing:(Duplicates-1)*DupSpacing,[3 1]);
    ExtTime=repmat(ExtTime,[1 Duplicates]) + (TimeOffset(:))';
end

end