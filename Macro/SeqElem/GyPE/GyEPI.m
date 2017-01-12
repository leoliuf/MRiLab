
function [GAmp,GTime]=GyEPI(p)

global VCtl;
global VVar;

t1Start=p.t1Start;
t2Middle=p.t2Middle;
Gy1Sign=p.Gy1Sign;
Gy2Sign=p.Gy2Sign;

% phase encoding
KyMax=(1/VCtl.RPhase)/2;
KydK=(2*KyMax)/VCtl.EPI_ETL;

% prephasing lob
p.tStart=t1Start;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KyMax - (VVar.PhaseCount-1)*(KydK/VCtl.EPI_ShotNum);
[GAmp1,GTime1]=GyAreaTrapezoid2(p);
p=[];

% blip lobs
p.Area=KydK;
p.Duplicates=1;
p.DupSpacing=0;
TimeOffset = (t2Middle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)-0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
GAmp2=[];
GTime2=[];
for i = 1: VCtl.EPI_ETL-1
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP;
    [GAmpt,GTimet]=GyAreaTrapezoid2(p);
    GAmp2=[GAmp2 GAmpt];
    GTime2=[GTime2 GTimet];
end

GAmp=[GAmp1*Gy1Sign GAmp2*Gy2Sign];
GTime=[GTime1 GTime2];

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
