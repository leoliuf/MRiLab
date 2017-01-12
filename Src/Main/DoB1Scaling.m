
function rfGain=DoB1Scaling(PulSeg,dt,ActFA)

global VObj;

flag=zeros(size(PulSeg));
ind=diff(abs(PulSeg));
flag(find(ind<0)+1)=1;
flag(ind>=0)=1;
rfGain=((ActFA/180)*pi)/(VObj.Gyro*sum(PulSeg.*flag)*dt);

%Old B1 scaling scheme
%switch PulType
%     case 'Rect' % 180 degree Nominal hard pulse
%         NomPulWidth=1e-3;
%         NomFA=180;
%         NomrfGain=0.119e-4;
%     case 'Sinc' % 180 degree Nominal 5 lob sinc pulse
%         NomPulWidth=1e-3;
%         NomFA=180;
%         NomrfGain=0.439e-4;
%     case 'Gauss' % 180 degree gaussian pulse
%         NomPulWidth=1e-3;
%         NomFA=180;
%         NomrfGain=0.238e-4;
% end
% 
% rfGain=NomrfGain*(NomPulWidth/PulWidth)*(ActFA/NomFA);

end