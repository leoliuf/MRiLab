

function DoToHDF5(Simuh)

% convert MRiLab output to HDF5 file which works with Gadgetron
global VCtl
global VSig
global VCoi
global VObj

vctl.protocolName               = VCtl.SeriesName;
vctl.systemVendor               = 'MRiLab';
vctl.systemModel                = '2013a';
vctl.systemFieldStrength_T      = single(VCtl.B0);
vctl.receiverChannels           = uint16(VCoi.RxCoilNum);
vctl.institutionName            = 'WIMR';
vctl.stationName                = 'L1122-E';
vctl.H1resonanceFrequency_Hz    = uint32(VCtl.B0 * VObj.Gyro/(2*pi));
vctl.ESMatrixSizeX              = uint16(VCtl.ResFreq);
vctl.ESMatrixSizeY              = uint16(VCtl.ResPhase);
vctl.ESMatrixSizeZ              = uint16(VCtl.SliceNum);
vctl.ESFOVX                     = single(VCtl.FOVFreq  * 1000);
vctl.ESFOVY                     = single(VCtl.FOVPhase * 1000);
vctl.ESFOVZ                     = single(VCtl.FOVSlice * 1000);
vctl.RSMatrixSizeX              = uint16(VCtl.ResFreq);
vctl.RSMatrixSizeY              = uint16(VCtl.ResPhase);
vctl.RSMatrixSizeZ              = uint16(VCtl.SliceNum);
vctl.RSFOVX                     = single(VCtl.FOVFreq  * 1000);
vctl.RSFOVY                     = single(VCtl.FOVPhase * 1000);
vctl.RSFOVZ                     = single(VCtl.FOVSlice * 1000);
vctl.trajectory                 = VCtl.TrajType;
vctl.TR                         = single(VCtl.TR);
vctl.TE                         = single(VCtl.TE);
vctl.BW                         = single(VCtl.BandWidth);
vctl.outputFile                 = [Simuh.OutputDir filesep 'Series' num2str(Simuh.ScanSeriesInd) '.h5'];

Sx=single(sum(reshape(VSig.Sx, length(VSig.Sx)/VObj.TypeNum, VObj.TypeNum),2));
Sy=single(sum(reshape(VSig.Sy, length(VSig.Sy)/VObj.TypeNum, VObj.TypeNum),2));
Kx=single(VSig.Kx);
Ky=single(VSig.Ky);
Kz=single(VSig.Kz);
vsig.S                          = [Sx'; Sy'];
vsig.K                          = [Kx; Ky; Kz];
vsig.echoNumber                 = uint32(VCtl.TEPerTR);
vsig.firstPhaseNumber           = uint32(VCtl.FirstPhNum);
vsig.secondPhaseNumber          = uint32(VCtl.SecondPhNum);
vsig.readoutNumber              = uint32(length(VSig.Sx)/(VCtl.TEPerTR*VCtl.FirstPhNum*VCtl.SecondPhNum*VCoi.RxCoilNum*VObj.TypeNum));

% convert MRiLab output to HDF5 file
DoMatToHDF5(vsig,vctl);


end