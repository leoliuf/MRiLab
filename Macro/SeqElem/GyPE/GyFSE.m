
function [GAmp,GTime]=GyFSE(p)

global VCtl;
global VVar;

tMiddle=p.tMiddle;
tGy1= p.tGy1;
tGy2= p.tGy2;
tOffset= p.tOffset;
Gy1Sign=p.Gy1Sign;
Gy2Sign=p.Gy2Sign;

% phase encoding
KyMax=(1/VCtl.RPhase)/2;
KydK=(2*KyMax)/VCtl.FSE_ETL;
p.Duplicates=1;
p.DupSpacing=0;

GAmp=[];
GTime=[];
TimeOffset = (tMiddle+VCtl.TEAnchorTime)-floor(VCtl.FSE_ETL/2)*VCtl.FSE_ESP;
for i = 1: VCtl.FSE_ETL
    % phase encoding
    p.tStart = TimeOffset + (i-1)*VCtl.FSE_ESP - tOffset;
    p.tEnd = p.tStart + tGy1;
    p.Area = (-(KyMax-(VVar.PhaseCount-1)*(KydK/VCtl.FSE_ShotNum)) + (i-1) * KydK) * Gy1Sign;
    [GAmpt,GTimet]=GyAreaTrapezoid(p); % unit m-1
    GAmp=[GAmp GAmpt];
    GTime=[GTime GTimet];
    
    % rephasing
    p.tStart = TimeOffset + (i-1)*VCtl.FSE_ESP + tOffset - tGy2;
    p.tEnd = p.tStart + tGy2;
    p.Area = (-(KyMax-(VVar.PhaseCount-1)*(KydK/VCtl.FSE_ShotNum)) + (i-1) * KydK) * Gy2Sign;
    [GAmpt,GTimet]=GyAreaTrapezoid(p);
    GAmp=[GAmp GAmpt];
    GTime=[GTime GTimet];
end

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);


end
