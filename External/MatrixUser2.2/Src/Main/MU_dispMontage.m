% MatrixUser, a multi-dimensional matrix analysis software package
% https://sourceforge.net/projects/matrixuser/
% 
% The MatrixUser is a matrix analysis software package developed under Matlab
% Graphical User Interface Developing Environment (GUIDE). It features 
% functions that are designed and optimized for working with multi-dimensional
% matrix under Matlab. These functions typically includes functions for 
% multi-dimensional matrix display, matrix (image stack) analysis and matrix 
% processing.
%
% Author:
%   Fang Liu <leoliuf@gmail.com>
%   University of Wisconsin-Madison
%   Aug-30-2014



% display montage
function MU_dispMontage(Temp,Event,Disp_Matrix,handles)
        
        % Montage slice selection checking
        if str2num(get(handles.Sli_from,'String'))>str2num(get(handles.Sli_to,'String'))
                errordlg('No slice is chosen for creating montage !');
                return;
        end
        if str2num(get(handles.Sli_from,'String'))<1
                set(handles.Sli_from,'String','1')
                return;
        end
        if str2num(get(handles.Sli_to,'String'))>handles.V.Layer
                set(handles.Sli_to,'String',num2str(handles.V.Layer))
                return;
        end

        % Montage layout initialization
        [Row,Column,Layer]=size(Disp_Matrix);
        ind=0;
        b_flag=0;
        for i=1:str2num(get(handles.Mont_row,'String'))
                for j=1:str2num(get(handles.Mont_col,'String'))
                        DMatrix((i-1)*Row+1:i*Row,(j-1)*Column+1:j*Column)=Disp_Matrix(:,:,str2num(get(handles.Sli_from,'String'))+ind);
                        ind=ind+1;
                        if ind>str2num(get(handles.Sli_to,'String'))-str2num(get(handles.Sli_from,'String'))
                                b_flag=1;
                                break;
                        end
                end
                if b_flag==1
                        break;
                end
        end
        

        %-------------------------Windows Contrast Change
        Color_map=handles.V.Color_map;
        Contrast_Low=handles.V.C_lower;
        Contrast_High=handles.V.C_upper;
        Contrast_Change=0;
        point=[0 0];
        point2=[0 0];
        Contrast_Interval=(Contrast_High-Contrast_Low)/100;
        %-------------------------End

        delete(handles.Cre_Mont);
        figure ('KeyReleaseFcn',@WindowKeyRelease,'KeyPressFcn',@WindowKeyPress, 'WindowScrollWheelFcn',@MouseScrollWheel,...
                'WindowButtonUpFcn',@MouseUp,'WindowButtonDownFcn', @MouseClick,'Name',['Display ' handles.V.Current_matrix ' Montage']);
        imagesc(DMatrix,[Contrast_Low Contrast_High]);
        colormap(Color_map);
        colorbar;

        
        
        function MouseScrollWheel (Temp, Event)
                if Contrast_Change==-1
                    Contrast_Low=Contrast_Low + Event.VerticalScrollCount*Contrast_Interval;
                end
                if Contrast_Change==1
                    Contrast_High=Contrast_High + Event.VerticalScrollCount*Contrast_Interval;
                end
                
                imagesc (DMatrix,[Contrast_Low Contrast_High]); 
                colormap(Color_map);
                colorbar;
                
        end

        function MouseClick(Temp,Event)
                tpoint=get(gca,'currentpoint');
                point=[round(tpoint(1)),round(tpoint(3))];

        end
        
        function MouseUp(Temp,Event)
                tpoint2=get(gca,'currentpoint');
                point2=[round(tpoint2(1)),round(tpoint2(3))];
                
                if sum(abs(point2-point))~=0
                    rectangle('Position',[point(1),point(2),point2(1)-point(1),point2(2)-point(2)],'EdgeColor',[0 1 0]);
                    DispS=DMatrix(point(2):point2(2),point(1):point2(1));
                    DispS=DispS(:);
                    tmean=mean(double(DispS));
                    tstd=std(double(DispS));
                    xlabel(['ROI mean:' num2str(tmean) '  ROI std:' num2str(tstd) '  RSD(%):' num2str(abs(tstd./tmean)*100)],'FontSize',18);
                end
        end
        
        function WindowKeyPress(Temp,Event)
                %------------------------------Windows Contrast Change
                if Event.Character=='l'
                    Contrast_Change=-1;
                elseif Event.Character=='u'
                    Contrast_Change=1;
                end
                %------------------------------End
        end
        
        function WindowKeyRelease(Temp,Event)
                Contrast_Change=0;
        end

end




