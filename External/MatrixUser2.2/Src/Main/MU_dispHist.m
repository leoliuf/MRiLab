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



% display histogram
function MU_dispHist(Temp,Event,Disp_Matrix,handles)

cla;

if get(handles.Include0,'Value')==1
    set(handles.Include0,'String','Exclude 0');
    set(handles.Include0_v,'String','*Note: voxels with value of 0 are included for statistical calculation.');
    TMatrix=double(Disp_Matrix(Disp_Matrix>=get(handles.B_lower,'Value') & Disp_Matrix<=get(handles.B_upper,'Value')));
else
    set(handles.Include0,'String','Include 0');
    set(handles.Include0_v,'String','*Note: voxels with value of 0 are NOT included for statistical calculation!!!');
    TMatrix=double(Disp_Matrix(Disp_Matrix~=0 & Disp_Matrix>=get(handles.B_lower,'Value') & Disp_Matrix<=get(handles.B_upper,'Value')));
end

set(handles.B_upper_v,'String',num2str(get(handles.B_upper,'Value')));
set(handles.B_lower_v,'String',num2str(get(handles.B_lower,'Value')));
set(handles.Max_v,'String',num2str(max(TMatrix)));
set(handles.Min_v,'String',num2str(min(TMatrix)));
set(handles.Mean_v,'String',num2str(mean(TMatrix)));
set(handles.Median_v,'String',num2str(median(TMatrix)));
set(handles.SD_v,'String',num2str(std(TMatrix)));
set(handles.Skewness_v,'String',num2str(skewness(TMatrix)));
set(handles.Kurtosis_v,'String',num2str(kurtosis(TMatrix)));
set(handles.Nin_v,'String',num2str(prctile(TMatrix,90)));
set(handles.Ten_v,'String',num2str(prctile(TMatrix,10)));

tmp=get(handles.Bin,'String');
binnum=ceil(str2num(tmp{get(handles.Bin,'Value')})*length(TMatrix)/100);

hist(handles.Hist,TMatrix,binnum);
n=hist(TMatrix,binnum);
line=max(n);

hold on;

tmp=get(handles.Histfit,'String');
if get(handles.Histfit,'Value')~=1
    try 
        histfit(TMatrix,binnum,tmp{get(handles.Histfit,'Value')});
    catch me
        errordlg({'Histogram fit failed.';me.message});
    end
end
axes(handles.Hist);
plot(mean(TMatrix).*ones(line+1,1),0:line,'-g');
plot(median(TMatrix).*ones(line+1,1),0:line,'-r');
plot(prctile(TMatrix,90).*ones(line+1,1),0:line,'-c');
plot(prctile(TMatrix,10).*ones(line+1,1),0:line,'-m');

hold off;

if strcmp(get(Temp,'String'),'FitTool')
    dfittool(TMatrix(:));
end

end




