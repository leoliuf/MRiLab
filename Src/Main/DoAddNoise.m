
function DoAddNoise
% Add noise in K-space data

global VSig;
global VCtl;

% Noise Reference
BWRef  = 1e3;
B0Ref  = 1.5;
NEXRef = 1;
ADCRef = 1e4;
VolRef = 1e-9;
NoiseRef = 1;

NoiseScale=(sqrt(VCtl.BandWidth/BWRef)*(VCtl.NoiseLevel/NoiseRef))...
          /(sqrt(VCtl.NEX/NEXRef)*(VCtl.B0/B0Ref)*(VCtl.RFreq*VCtl.RPhase*VCtl.RSlice/VolRef)*sqrt(VCtl.ResFreq*VCtl.ResPhase*VCtl.SliceNum/ADCRef));
      
VSig.Sx=NoiseScale*randn(size(VSig.Sx))+VSig.Sx;
VSig.Sy=NoiseScale*randn(size(VSig.Sy))+VSig.Sy;

end