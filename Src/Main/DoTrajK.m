
function DoTrajK(handles)

global VObj;
global VMag;
global VCtl;
global VSig;
global VCoi;

%preserve VObj VMag & VCoi
VTmpObj=VObj;
VTmpMag=VMag;
VTmpCoi=VCoi;

handles.Simuh=guidata(handles.Simuh.SimuPanel_figure);
DoDisableButton([],[],handles.Simuh);
%% Do K-Space Traj
try
    % Read tab parameters
    fieldname=fieldnames(handles.Attrh2);
    for i=1:length(fieldname)/2
        try
            eval(['TK.' fieldname{i*2} '=[' get(handles.Attrh2.(fieldname{i*2}),'String') '];']);
        catch me
            TAttr=get(handles.Attrh2.(fieldname{i*2}),'String');
            eval(['TK.' fieldname{i*2} '=''' TAttr{get(handles.Attrh2.(fieldname{i*2}),'Value')}  ''';']);
        end
    end
    
    % Prescan config
    DoPreScan(handles.Simuh);
    
    % Create SpinWatcher VOtk, VMtk & VCtk
    VOtk=VObj;
    VOtk.SpinNum=1;
    VOtk.TypeNum=1;
    VOtk.Rho=1;
    VOtk.T1=1;
    VOtk.T2=0.1;
    VOtk.T2Star=0.01;
    VOtk.XDim=1;
    VOtk.YDim=1;
    VOtk.ZDim=1;
    VOtk.Mx= 0;
    VOtk.My= 0;
    VOtk.Mz= 1;

    % Gradient Grid
    VMtk=VMag;
    VMtk.Gxgrid=0;
    VMtk.Gygrid=0;
    VMtk.Gzgrid=0;
    VMtk.dB0=0;
    VMtk.dWRnd=0;
    VMtk.FRange=1;

    % Coil
    VCtk=VCoi;
    VCtk.TxCoilmg=1;
    VCtk.TxCoilpe=0;
    VCtk.TxCoilNum=1;
    VCtk.RxCoilx=1;
    VCtk.RxCoily=0;
    VCtk.RxCoilNum=1;
    
    %% Spin execution
    VObj=VOtk;
    VMag=VMtk;
    VCoi=VCtk;
    
    % Generate Pulse line
    DoPulseGen(handles);
    
    % Simulation Process
    try
        VCtl.CS=double(VObj.ChemShift*VCtl.B0);
        VCtl.RunMode=int32(0); % Image scan
        VCtl.MaxThreadNum=int32(handles.Simuh.CPUInfo.NumThreads);
        DoDataTypeConv(handles.Simuh);
        DoScanAtCPU; % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
    catch me
        error_msg{1,1}='ERROR!!! Scan process aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
        %recover VObj
        VObj=VTmpObj;
        VMag=VTmpMag;
        VCoi=VTmpCoi;
        return;
    end
catch me
    error_msg{1,1}='ERROR!!! Spin execution process aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    %recover VObj
    VObj=VTmpObj;
    VMag=VTmpMag;
    VCoi=VTmpCoi;
    return;
end

Kx=VSig.Kx;
Ky=VSig.Ky;
Kz=VSig.Kz;

%recover VObj
VObj=VTmpObj;
VMag=VTmpMag;
VCoi=VTmpCoi;

pause(0.1);

switch TK.RenderMode
    case 'VTK'
        % VTK 3D rendering
        switch TK.RenderPoint
            case 'off'
                DoKSpaceTrajVTK([Kx(:)';Ky(:)';Kz(:)'],ones(size(Kx(:)'))*1,0);
            case 'on'
                DoKSpaceTrajVTK([Kx(:)';Ky(:)';Kz(:)'],ones(size(Kx(:)'))*1,1);
        end
    case 'Matlab'
        % Matlab 3D plot
        figure('Color','k');
        switch TK.RenderPoint
            case 'off'
                Ktraj=plot3(Kx(:),Ky(:),Kz(:),'w-');
                grid on;
            case 'on'
                Ktraj=quiver3(Kx(:),Ky(:),Kz(:),[diff(Kx(:));0],[diff(Ky(:));0],[diff(Kz(:));0],'w-');
                set(Ktraj,'AutoScale','off');
        end
        
                set(gca,'Color','k','xcolor','c','ycolor','c','zcolor','c');
        set(gca,'ydir','reverse');
        xlabel('Kx','Color','w');
        ylabel('Ky','Color','w');
        zlabel('Kz','Color','w');
        title('K-space Traj.','Color','w');
end

end