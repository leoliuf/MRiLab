

function ExecFlag=DoGradChk

global VSeq
global VCtl


ExecFlag = 1;
GradTolerance = abs(VCtl.MaxGrad * 0.005);
SRTolerance = abs(VCtl.MaxSlewRate * 0.005);
% check Gz
Flags = VSeq.flagsLine(2,:);
t = VSeq.tsLine(Flags~=0);
dt =  diff(t);
dG =  diff(VSeq.GzAmpLine);

SlewRate = dG./dt;

if ~isempty(find((abs(SlewRate)-VCtl.MaxSlewRate)>SRTolerance, 1))
    
    disp(['GzSS Max SlewRate ' num2str(max(abs(SlewRate)))]);
    
    errordlg('GzSS exceeds maximum allowed gradient slew rate!');
    ExecFlag = 0;
end

if ~isempty(find((abs(VSeq.GzAmpLine)-VCtl.MaxGrad)>GradTolerance, 1))
    
    disp(['GzSS Max Gradient ' num2str(max(abs(VSeq.GzAmpLine)))]);
    
    errordlg('GzSS exceeds maximum allowed gradient amplitude!');
    ExecFlag = 0;
end

% check Gy
Flags = VSeq.flagsLine(3,:);
t = VSeq.tsLine(Flags~=0);
dt =  diff(t);
dG =  diff(VSeq.GyAmpLine);

SlewRate = dG./dt;

if ~isempty(find((abs(SlewRate)-VCtl.MaxSlewRate)>SRTolerance, 1))
    
    disp(['GyP Max SlewRate ' num2str(max(abs(SlewRate)))]);
    
    errordlg('GyP exceeds maximum allowed gradient slew rate!');
    ExecFlag = 0;
end

if ~isempty(find((abs(VSeq.GyAmpLine)-VCtl.MaxGrad)>GradTolerance, 1))
    
    disp(['GyP Max Gradient ' num2str(max(abs(VSeq.GyAmpLine)))]);
    
    errordlg('GyP exceeds maximum allowed gradient amplitude!');
    ExecFlag = 0;
end

% check Gx
Flags = VSeq.flagsLine(4,:);
t = VSeq.tsLine(Flags~=0);
dt =  diff(t);
dG =  diff(VSeq.GxAmpLine);

SlewRate = dG./dt;

if ~isempty(find((abs(SlewRate)-VCtl.MaxSlewRate)>SRTolerance, 1))
    
    disp(['GxR Max SlewRate ' num2str(max(abs(SlewRate)))]);
    
    errordlg('GxR exceeds maximum allowed gradient slew rate!');
    ExecFlag = 0;
    
end

if ~isempty(find((abs(VSeq.GxAmpLine)-VCtl.MaxGrad)>GradTolerance, 1))
    
    disp(['GxR Max Gradient ' num2str(max(abs(VSeq.GxAmpLine)))]);
    
    errordlg('GxR exceeds maximum allowed gradient amplitude!');
    ExecFlag = 0;
end


end