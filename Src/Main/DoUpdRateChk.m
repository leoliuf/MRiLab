

function ExecFlag=DoUpdRateChk

global VSeq
global VCtl


ExecFlag = 1;
URTolerance = -abs(VCtl.MinUpdRate * 0.01);
% check update rate
% check rf
TxCoilID=unique(VSeq.rfCoilLine);
for i = 1: length(TxCoilID)
    Flags = VSeq.flagsLine(1,:);
    t = VSeq.tsLine(Flags~=0);
    t = t(VSeq.rfCoilLine == TxCoilID(i));
    dt =  diff(t);
    dt (dt < 0.5*eps) =[]; % avoid unique function rounding threshold (0.5*eps)
    if ~isempty(find((abs(dt)-VCtl.MinUpdRate)<URTolerance, 1))
        errordlg(['rf' num2str(TxCoilID(i)) ' sequence line exceeds minimum update rate!']);
        ExecFlag = 0;
    end
end

% check Gz
Flags = VSeq.flagsLine(2,:);
t = VSeq.tsLine(Flags~=0);
dt =  diff(t);
dt (dt < 0.5*eps) =[];
if ~isempty(find((abs(dt)-VCtl.MinUpdRate)<URTolerance, 1))
    errordlg('GzSS sequence line exceeds minimum update rate!');
    ExecFlag = 0;
end

% check Gy
Flags = VSeq.flagsLine(3,:);
t = VSeq.tsLine(Flags~=0);
dt =  diff(t);
dt (dt < 0.5*eps) =[];
if ~isempty(find((abs(dt)-VCtl.MinUpdRate)<URTolerance, 1))
    errordlg('GyP sequence line exceeds minimum update rate!');
    ExecFlag = 0;
end

% check Gx
Flags = VSeq.flagsLine(4,:);
t = VSeq.tsLine(Flags~=0);
dt =  diff(t);
dt (dt < 0.5*eps) =[];
if ~isempty(find((abs(dt)-VCtl.MinUpdRate)<URTolerance, 1))
    errordlg('GxR sequence line exceeds minimum update rate!');
    ExecFlag = 0;
end

end