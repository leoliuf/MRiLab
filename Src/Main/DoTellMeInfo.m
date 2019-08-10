
function TooltipString=DoTellMeInfo(var)

Units = [];
Tips = '';
switch var
    
    %% Imaging Tab
    case 'BandWidth'
        Units ='Hz';
        Tips ='Full receiver bandwidth';
    case 'FOVFreq'
        Units ='m';
        Tips ='Field of view in the frequency encoding direction';
    case 'FOVPhase'
        Units ='m';
        Tips ='Field of view in the first phase encoding direction';
    case 'FlipAng'
        Units ='Degree';
        Tips ='Nominal flip angle of excitation pulse';
    case 'FreqDir'
        Tips ='Frequency encoding direction';
    case 'ResFreq'
        Tips ='Number of voxels in frequency encoding direction';
    case 'ResPhase'
        Tips ='Number of voxels in the first phase encoding direction';
    case 'ScanPlane'
        Tips ='The scanning plane';
    case 'SliceNum'
        Tips ='The number of encoding slice';
    case 'SliceThick'
        Units ='m';
        Tips ='The thickness of one slice';
    case 'TE'
        Units ='s';
        Tips ='The time of echo';
    case 'TEPerTR'
        Tips ='The number of echoes in multiple echo mode, using a number greater than one requires ''MultiEcho'' tab to be loaded';
    case 'TR'
        Units ='s';
        Tips ='The time of repetition';
        %% Advanced Tab
    case 'MasterTxCoil'
        Tips ='The master transmitting coil ID in multi RF transmitting mode';
    case 'MultiTransmit'
        Tips ='The flag for turning on and off multi RF transmitting mode, default mode is ''off'' for single RF transmitting';
    case 'NEX'
        Tips ='The number of excitation';
    case 'NoFreqAlias'
        Tips ='The flag for avoiding aliasing in frequency encoding direction, default ''on'' truncates object outside field of view in frequency encoding direction';
    case 'NoPhaseAlias'
        Tips ='The flag for avoiding aliasing in the first phase encoding direction, default ''on'' truncates object outside field of view in the first phase encoding direction';
    case 'NoSliceAlias'
        Tips ='The flag for avoiding aliasing in the second phase encoding (i.e. slice encoding) direction, default ''on'' truncates object outside field of view in slice encoding direction';
    case 'Shim'
        Tips ='Main static field shimming';
    case 'TEAnchor'
        Tips ='The flag for choosing TE time offset regarding the excitation RF pulse';
        %% Hardware Tab
    case 'B0'
        Units ='T';
        Tips ='Main static magnetic field strength';
    case 'B1Level'
        Units ='T';
        Tips ='A linear scale factor for B1. The input B1+ field with magnitude of this number produces nominal flip angle';
    case 'E1Level'
        Units ='T';
        Tips ='A linear scale factor for E1. When calculating spatial SAR, the input E1+ field is scaled by a factor of nominal RF amplitude divided by this number';
    case 'MaxGrad'
        Units ='T/m';
        Tips ='Maximum allowable gradient strength';
    case 'MaxSlewRate'
        Units ='T/m/s';
        Tips ='Maximum allowable gradient slew rate';
    case 'MinUpdRate'
        Units ='s';
        Tips ='Minimum update time on generating sequence waveform';
    case 'Model'
        Tips ='Model type';
    case 'NoiseLevel'
        Tips ='The level of adjustable noise, the higher the number, the more noise';
    case 'PulseType'
        Tips ='The type of generated sequence pulse';
    case 'SpinPerVoxel'
        Tips ='The number of spins in each voxel. Default one spin per voxel treats T2* equal to T2, use a number greater than one to simulate T2* effect based on T2Star input (linear simulation time cost)';
        %% Recon Tab
    case 'AutoRecon'
        Tips ='The flag for turning on and off automatic image reconstruction after MR signal acquisition';
    case 'ExternalEng'
        Tips ='User defined script for image reconstruction';
    case 'OutputType'
        Tips ='The type of output data including both simulated image and signal';
    case 'ReconEng'
        Tips ='The image reconstruction engine, choosing ''External'' uses external engine which requires ''ExternalEng'' to be provided';
    case 'ReconType'
        Tips ='The type of image reconstruction';
        %% CV Tab
    case 'CV1'
        Tips ='Controllable variable 1';
    case 'CV2'
        Tips ='Controllable variable 2';
    case 'CV3'
        Tips ='Controllable variable 3';
    case 'CV4'
        Tips ='Controllable variable 4';
    case 'CV5'
        Tips ='Controllable variable 5';
    case 'CV6'
        Tips ='Controllable variable 6';
    case 'CV7'
        Tips ='Controllable variable 7';
    case 'CV8'
        Tips ='Controllable variable 8';
    case 'CV9'
        Tips ='Controllable variable 9';
    case 'CV10'
        Tips ='Controllable variable 10';
    case 'CV11'
        Tips ='Controllable variable 11';
    case 'CV12'
        Tips ='Controllable variable 12';
    case 'CV13'
        Tips ='Controllable variable 13';
    case 'CV14'
        Tips ='Controllable variable 14';
        %% SpecialTech Tab
    case 'GRAPPA'
        Tips ='GRAPPA';
    case 'GM'
        Tips ='Generalized Multi-pool exchanging simulation';
    case 'FSE'
        Tips ='Fast Spin Echo';
    case 'EPI'
        Tips ='Echo Planar Imaging';
    case 'DummyPulse'
        Tips ='Dummy pulse';
    case 'CEST'
        Tips ='Chemical Exchange Saturation Transfer simulation';
    case 'PartialEcho'
        Tips ='Partial echo';
    case 'MultiEcho'
        Tips ='Multi echo';
    case 'MT'
        Tips ='Magnetization Transfer simulation';
    case 'ME'
        Tips ='Multiple pool spin Exchange simulation';
    case 'IRPrep'
        Tips ='Inversion recovery preparation';
    case 'T2Prep'
        Tips ='T2 decay preparation';
    case 'Gridding'
        Tips ='Non-Cartesian gridding';
    case 'Spiral'
        Tips ='Spiral imaging';
    case 'SENSE'
        Tips ='SENSE';
    case 'Radial'
        Tips ='Radial imaging';
    case 'RTRecon'
        Tips ='Real Time reconstruction';
    case 'ZeroFilling'
        Tips ='Zero filling k-space';
    case 'VIPR'
        Tips ='VIPR';
    case 'DP_Flag'
        Tips ='The flag for turning on and off dummy pulse';
    case 'DP_FlipAng'
        Units ='Degree';
        Tips ='The flip angle of excitation pulse for dummy pulse';
    case 'DP_Num'
        Tips ='The number of TRs for dummy pulse';
    case 'DP_TR'
        Units ='s';
        Tips ='The time of repetition for dummy pulse';
    case 'EPI_ESP'
        Units ='s';
        Tips ='The echo spacing for EPI';
    case 'EPI_ETL'
        Tips ='The echo train length for EPI';
    case 'EPI_EchoShifting'
        Tips ='The flag for turning on and off echo shifting';
    case 'EPI_ShotNum'
        Tips ='The number of EPI shots, multi shot EPI uses interleave mode';
    case 'FSE_ESP'
        Units ='s';
        Tips ='The echo spacing for FSE';
    case 'FSE_ETL'
        Tips ='The echo train length for FSE';
    case 'FSE_ShotNum'
        Tips ='The number of FSE shots, multi shot FSE uses interleave mode';
    case 'G_Deapodization'
        Tips ='The flag for turning on and off kernel deapodization (i.e. dividing reconstructed image with the iFFT of the gridding kernel)';
    case 'G_KernelSample'
        Tips ='The number of kernel sample point, the more sample points, the better kernel approximation';
    case 'G_KernelWidth'
        Tips ='The full width of kernel in the unit of gridding grid';
    case 'G_OverGrid'
        Tips ='The over gridding factor';
    case 'G_Truncation'
        Tips ='The flag for turning on and off image truncation for reconstructed image';
    case 'TI'
        Units ='s';
        Tips ='The time of inversion recovery';
    case 'MT_Flag'
        Tips ='The flag for turning on and off Magnetization Transfer simulation';
    case 'ME_Flag'
        Tips ='The flag for turning on and off Multiple pool spin Exchange simulation';
    case 'CEST_Flag'
        Tips ='The flag for turning on and off Chemical Exchange Saturation Transfer simulation';
    case 'GM_Flag'
        Tips ='The flag for turning on and off Generalized Multi-pool exchanging simulation';
    case 'RTR_Flag'
        Tips ='The flag for turning on and off real time reconstruction';
    case 'PlotK_Flag'
        Tips ='The flag for turning on and off real time k-space plotting';
    case 'DelayTime'
        Tips ='The delay time for refreshing graphics';
    case 'ME_TEs'
        Units ='s';
        Tips ='An array of multiple echo values';
    case 'R_AngPattern'
        Tips ='The pattern for sampling the angle in k-space';
    case 'R_AngRange'
        Tips ='The range of sampling angle';
    case 'R_SampPerSpoke'
        Tips ='The number of sampling points in each spoke';
    case 'R_SpokeNum'
        Tips ='The number of sampling spokes';
    case 'Sh_X'
        Tips ='The constant for X term';
    case 'Sh_Y'
        Tips ='The constant for Y term';
    case 'Sh_Z'
        Tips ='The constant for Z term';
    case 'Sh_ZX'
        Tips ='The constant for ZX term';
    case 'Sh_ZY'
        Tips ='The constant for ZY term';
    case 'Sh_Z2'
        Tips ='The constant for Z^2 term';
    case 'Sh_XYZ'
        Tips ='The constant for XYZ term';
    case 'Sh_X2_Y2'
        Tips ='The constant for (X^2)(Y^2) term';
    case 'S_ShotNum'
        Tips ='The number of spiral interleaves';
    case 'S_GradientEff'
        Tips ='A linear scale factor for adjusting maximum allowable gradient in spiral design';
    case 'S_F1'
        Tips ='A scale factor for varying FOV with k-space radius r, as FOV(r) = F0 + F1*r + F2*r*r (in variable density spiral design)';
    case 'S_F2'
        Tips ='A scale factor for varying FOV with k-space radius r, as FOV(r) = F0 + F1*r + F2*r*r (in variable density spiral design)';
    case 'tT2Prep'
        Units ='s';
        Tips ='The time of T2 decay preparation';
    case 'ZF_Kz'
        Tips ='The zero filling factor in Kz';
    case 'ZF_Ky'
        Tips ='The number of point in Ky after zero filling';
    case 'ZF_Kx'
        Tips ='The number of point in Kx after zero filling';
    case 'ChemShift'
        Units ='Hz/T';
        Tips ='The chemical shift of the spin';
    case 'Gyro'
        Units ='rad/s/T';
        Tips ='The gyromagnetic ratio of the spin';
    case 'Rho'
        Tips ='The spin density of the spin';
    case 'T1'
        Units ='s';
        Tips ='The longitudinal relaxation time';
    case 'T2'
        Units ='s';
        Tips ='The transverse relaxation time';
    case 'TypeNum'
        Tips ='The number of spin species';
    case 'ZCenter'
        Tips ='The index of the centeral spin in Z direction';
    case 'ZSpin'
        Tips ='The number of the spins in Z direction';
    case 'ZSpinGap'
        Units ='m';
        Tips ='The distance between adjacent spins in Z direction';
    case 'XCenter'
        Tips ='The index of the centeral spin in X direction';
    case 'XSpin'
        Tips ='The number of the spins in X direction';
    case 'XSpinGap'
        Units ='m';
        Tips ='The distance between adjacent spins in X direction';
    case 'Spat_Flag'
        Tips ='The flag to turn on and off 2D spatial RF analysis';
    case 'YCenter'
        Tips ='The index of the centeral spin in Y direction';
    case 'YSpin'
        Tips ='The number of the spins in Y direction';
    case 'YSpinGap'
        Units ='m';
        Tips ='The distance between adjacent spins in Y direction';
    case 'FreqRes'
        Tips ='The number of linear frequency sample points';
    case 'FreqUpLimit'
        Units ='Hz';
        Tips ='The upper limit of frequency range';
    case 'FreqDownLimit'
        Units ='Hz';
        Tips ='The lower limit of frequency range';
    case 'Freq_Flag'
        Tips ='The flag to turn on and off Spatial-Spectral RF analysis';
    case 'ConstantGrad'
        Units ='T/m';
        Tips ='The constant gradient applied when gradient tab is empty';
    case 'dB0'
        Units ='T';
        Tips ='The main static magnetic field offset';
        %% Pulse Waveform
    case 'tS'
        Units ='s';
        Tips ='The starting time point in TR section, any waveform timing in this pulse group is relative to this time point';
    case 'tE'
        Units ='s';
        Tips ='The ending time point in TR section, any waveform timing in this pulse group will be truncated after this time point';
    case 'TRStart'
        Tips ='The starting TR number';
    case 'TREnd'
        Tips ='The ending TR number';
    case 'Freq'
        Tips ='The occurrence frequency (e.g. 1 means occurring every TR section, 5 means occurring every 5 TR sections)';
    case 'Moments'
        Tips ='The flag for turning on and off the zeroth moment display for the gradient';
    case 'LineMarker'
        Tips ='The flag for turning on and off waveform line marker';
    case 'RenderMode'
        Tips ='The k-space rendering mode';
    case 'RenderPoint'
        Tips ='The flag for turning on and off k-space point rendering';
    case 'Tar'
        Tips ='The flag for turning on and off sequence deployment for Toppe';
    case 'PlayToppeMovie'
        Tips ='The flag for turning on and off Toppe movie playback';
    case 'NumTRSkip'
        Tips ='The number of TR sections to skip during Toppe movie playback';
    case 'PlayPulseqMovie'
        Tips ='The flag for turning on and off Pulseq movie playback';
    case 'ShowUnit'
        Tips ='The Pulseq display time unit';
    case 'ShowNum'
        Tips ='The number of time sections to show during Pulseq movie playback';
    case 'Apod'
        Tips ='Apodization methods for RF pulse';
    case 'FA'
        Units ='Degree';
        Tips ='Prescribed flip angle';
    case 'TBP'
        Tips ='The time bandwidth product of RF pulse';
    case 'dt'
        Units ='s';
        Tips ='The time interval of sample points';
    case 'rfPhase'
        Units ='rad';
        Tips ='RF pulse phase';
    case 'rfFreq'
        Units ='Hz';
        Tips ='RF pulse frequency offset';
    case 'tStart'
        Units ='s';
        Tips ='The starting time';
    case 'tEnd'
        Units ='s';
        Tips ='The ending time';
    case 'Switch'
        Tips ='The flag for turning on and off this pulse';
    case 'AnchorTE'
        Tips ='The flag for turning on and off TE reference, TE is calculated from this RF pulse if this flag is turned on';
    case 'Duplicates'
        Tips ='The number of the pulse duplicates, used for creating multiple pulses with the same shape';
    case 'DupSpacing'
        Units ='s';
        Tips ='The time spacing between pulse duplicates';
    case 'CoilID'
        Tips ='The ID of the coil element';
    case 'Notes'
        Tips ='The notes of this object';
    case 'PW'
        Tips ='The measure of the pulse width in Fermi RF pulse';
    case 'SLRPulseType'
        Tips ='The type of this SLR pulse, including ''st''(small tip angle pulse), ''ex''(excitation pulse), ''se''(spin-echo pulse), ''sat''(saturation pulse) and ''inv''(inversion pulse)';
    case 'FilterType'
        Tips ='The type of the applied filter design method, including ''ls''(least squares), ''min''(minimum phase), ''max''(maximum phase), ''pm''(Parks-McClellan equal ripple), and ''ms''(Hamming windowed sinc)';
    case 'PRipple'
        Tips ='The ripple factor at passband';
    case 'SRipple'
        Tips ='The ripple factor at stopband';
    case 'Adiab'
        Tips ='The adiabatic factor';
    case 'MaxB1'
        Units ='T';
        Tips ='The maximum B1 field';
    case 'MaxFreq'
        Units ='Hz';
        Tips ='The maximum RF frequency';
    case 'Lambda'
        Tips ='The lambda adiabatic factor';
    case 'Beta'
        Tips ='The beta adiabatic factor';
    case 'BIRFlag'
        Tips ='The type of BIR pulse, including ''BIR-1'', ''BIR-2'' and ''BIR-4''';
    case 'BIREFFlag'
        Tips ='The type of BIREF pulse, including ''BIREF-1'', ''BIREF-2a'' and ''BIREF-2b''';
    case 'rfGain'
        Tips ='The standard deviation of the normal distribution';
    case 'rfFile'
        Tips ='The path to the file that stores the RF pulse data, quoted using single quotes';
    case 't2Start'
        Units ='s';
        Tips ='The second gradient pulse starting time';
    case 't2End'
        Units ='s';
        Tips ='The second gradient pulse ending time';
    case 'tRamp'
        Units ='s';
        Tips ='The pulse ramp time from zero to plateau, assume symmetric ramp on both side';
    case 'GzAmp'
        Units ='T';
        Tips ='The amplitude of the Gz pulse';
    case 'Gz1Sign'
        Tips ='The polarity of the first gradient pulse, set 0 for nulling';
    case 'Gz2Sign'
        Tips ='The polarity of the second gradient pulse, set 0 for nulling';
    case 'Gz3Sign'
        Tips ='The polarity of the last gradient pulse, set 0 for nulling';
    case 'sRamp'
        Tips ='The sample points on the ramp, use the value of 2 for ignoring the area under the ramp, use values greater than 2 for counting the ramp area';
    case 'Area'
        Units ='1/m';
        Tips ='The area under this gradient pulse';
    case 'nCycles'
        Tips ='The number of cycles of phase across the pixel size';
    case 't1Start'
        Units ='s';
        Tips ='The first gradient pulse starting time';
    case 't1End'
        Units ='s';
        Tips ='The first gradient pulse ending time';
    case 'GzFile'
        Tips ='The path to the file that stores the Gz pulse data, quoted using single quotes';
    case 'GyFile'
        Tips ='The path to the file that stores the Gy pulse data, quoted using single quotes';
    case 'GxFile'
        Tips ='The path to the file that stores the Gx pulse data, quoted using single quotes';
    case 'ADCFile'
        Tips ='The path to the file that stores the ADC pulse data, quoted using single quotes';
    case 'GyAmp'
        Units ='T';
        Tips ='The amplitude of the Gy pulse';
    case 'Gy1Sign'
        Tips ='The polarity of the first gradient pulse, set 0 for nulling';
    case 'Gy2Sign'
        Tips ='The polarity of the second gradient pulse, set 0 for nulling';
    case 'Gy3Sign'
        Tips ='The polarity of the last gradient pulse, set 0 for nulling';
    case 't2Middle'
        Units ='s';
        Tips ='The second encoding gradient pulse middle time';
    case 't3Start'
        Units ='s';
        Tips ='The last gradient pulse starting time';
    case 'tMiddle'
        Units ='s';
        Tips ='The middle time of the pulse';
    case 'tOffset'
        Units ='s';
        Tips ='The time offset of the gradient pulse';
    case 'tGy1'
        Units ='s';
        Tips ='The duration of the first gradient pulse';
    case 'tGy2'
        Units ='s';
        Tips ='The duration of the second gradient pulse';
    case 'GxAmp'
        Units ='T';
        Tips ='The amplitude of the Gx pulse';
    case 'Gx1Sign'
        Tips ='The polarity of the first gradient pulse, set 0 for nulling';
    case 'Gx2Sign'
        Tips ='The polarity of the second gradient pulse, set 0 for nulling';
    case 'Gx3Sign'
        Tips ='The polarity of the last gradient pulse, set 0 for nulling';
    case 'sSample'
        Tips ='The number of linear sample points when ADC flag is 1';
    case 'Ext'
        Tips ='The Ext flag';
    case 'isVardens'
        Tips ='The flag for turning on and off variable density spiral design';
    case 'InOut'
        Tips ='Spiral in or out';
        %% Others
    case 'Name'
        Tips ='The name of the structure';
    case 'Type'
        Tips ='A description about the phantom type';
    case 'XDim'
        Tips ='The number of voxels in X direction';
    case 'YDim'
        Tips ='The number of voxels in Y direction';
    case 'ZDim'
        Tips ='The number of voxels in Z direction';
    case 'XDimRes'
        Units ='m';
        Tips ='The spatial resolution in X direction';
    case 'YDimRes'
        Units ='m';
        Tips ='The spatial resolution in Y direction';
    case 'ZDimRes'
        Units ='m';
        Tips ='The spatial resolution in Z direction';
    case 'Grid'
        Tips ='Turn on and off grid';
    case 'Box'
        Tips ='Turn on and off boundary box';
    case 'CameraTool'
        Tips ='Hide or show Matlab camera tool';
    case 'Color'
        Tips ='The display color';
    case 'Alpha'
        Tips ='The display transparency';
    case 'Radius'
        Units ='m';
        Tips ='The radius of the object';
    case 'CenterX'
        Units ='m';
        Tips ='The X coordinate of the object center';
    case 'CenterY'
        Units ='m';
        Tips ='The Y coordinate of the object center';
    case 'CenterZ'
        Units ='m';
        Tips ='The Z coordinate of the object center';
    case 'FaceNum'
        Tips ='The number of the faces for the object';
    case 'TypeIdx'
        Tips ='An index number of the spin species, used when the phantom has multiple spin species. The index must not exceed the ''TypeNum''';
    case 'TypeFlag'
        Tips ='A flag number for describing the type of the spin, 0 for free pool and 1 for bound pool';
    case 'LineShapeFlag'
        Tips ='A flag number for describing RF saturation line shape for bound proton pool, 0 for super-Lorentzian and 1 for Gaussian (:ToDo), the flag is ignored for free pool';
    case 'ECon'
        Units ='S/m';
        Tips ='A array with size of [1 3] for tissue electrical conductivity (optional)';
    case 'MassDen'
        Units ='kg/m^3';
        Tips ='The tissue mass density (optional)';
    case 'T2Star'
        Units ='s';
        Tips ='The T2* relaxation time';
    case 'K'
        Units ='1/s';
        Tips ='A array with the size of [1 TypeNum] for describing the exchange rate of the spin, ignored for regular phantom';
    case 'RadiusX'
        Units ='m';
        Tips ='The X semi-axis length of the ellipsoid';
    case 'RadiusY'
        Units ='m';
        Tips ='The Y semi-axis length of the ellipsoid';
    case 'RadiusZ'
        Units ='m';
        Tips ='The Z semi-axis length of the ellipsoid';
    case 'Length'
        Units ='m';
        Tips ='The length of the object';
    case 'Height'
        Units ='m';
        Tips ='The height of the pyramid';
    case 'Colormap'
        Tips ='The colormap for the field';
    case 'CLimDown'
        Tips ='The lower bound of color limits';
    case 'CLimUp'
        Tips ='The upper bound of color limits';
    case 'CoilDisplay'
        Tips ='The flag for turning on and off coil display';
    case 'CoilShow'
        Tips ='The flag for choosing active coil for field display';
    case 'Mode'
        Tips ='The B1 field display mode';
    case 'FieldType'
        Tips ='The flag to choose B1 field or E1 field, note E1 field only support ''Magnitude'' display mode';
    case 'Plane'
        Tips ='The flag for activating field slicing plane';
    case 'Azimuth'
        Units ='rad';
        Tips ='The azimuth angle of the plane';
    case 'Elevation'
        Units ='rad';
        Tips ='The elevation angle of the plane';
    case 'PosZ'
        Units ='m';
        Tips ='The Z position of object center';
    case 'PosY'
        Units ='m';
        Tips ='The Y position of object center';
    case 'PosX'
        Units ='m';
        Tips ='The X position of object center';
    case 'CurrentDir'
        Tips ='The current direction in the coil circle, 1 for clockwise, -1 for counterclockwise';
    case 'Scale'
        Tips ='The scale factor for the field amplitude';
    case 'Segment'
        Tips ='The number of line segments for approximating circle, MRiLab requires the same ''Segment'' for each coil circle';
    case 'Width'
        Units ='m';
        Tips ='The width of the object';
    case 'B1File'
        Tips ='The path to the file that stores the B1 field data, quoted using single quotes';
    case 'E1File'
        Tips ='The path to the file that stores the E1 field data, quoted using single quotes';
    case 'Interp'
        Tips ='The interpolation method';
    case 'GradZ'
        Tips ='The linear gradient in Z direction';
    case 'GradY'
        Tips ='The linear gradient in Y direction';
    case 'GradX'
        Tips ='The linear gradient in X direction';
    case 'DeltaZ'
        Units ='m';
        Tips ='The width of Gaussian function in Z direction';
    case 'DeltaY'
        Units ='m';
        Tips ='The width of Gaussian function in Y direction';
    case 'DeltaX'
        Units ='m';
        Tips ='The width of Gaussian function in X direction';
    case 'Equation'
        Tips ='A field described with a symbolic equation';
    case 'MagFile'
        Tips ='The path to the file that stores the dB0 field data, quoted using single quotes';
    case 'GradLine'
        Tips ='The gradient sequence line';
    case 'DispMode'
        Tips ='The display mode';
    case 'GradZEqu'
        Tips ='A symbolic equation for gradient field vector in Z direction';
    case 'GradYEqu'
        Tips ='A symbolic equation for gradient field vector in Y direction';
    case 'GradXEqu'
        Tips ='A symbolic equation for gradient field vector in X direction';
    case 'GradFile'
        Tips ='The path to the file that stores the gradient field data, quoted using single quotes';
    case 'Object'
        Tips ='The object model, currently only supports ''Sphere''';
    case 'ViewPoint'
        Tips ='A default view point';
    case 'ZoomOut'
        Tips ='A factor of view zoom out';
    case 'Sample'
        Tips ='The sample steps between two adjacent positions during movement';
    case 'Repeat'
        Tips ='The repeat time of playback';
    case 'Direction'
        Tips ='A vector describing translation direction in 3D space';
    case 'Displacement'
        Units ='m';
        Tips ='An equation of translation displacement pattern with respect to time';
    case 'Axis'
        Tips ='A vector describing rotation axis in 3D space';
    case 'Angle'
        Units ='rad';
        Tips ='An equation of rotation angle with respect to time';
    case 'LocZ'
        Tips ='The Z location of the selected voxel';
    case 'LocY'
        Tips ='The Y location of the selected voxel';
    case 'LocX'
        Tips ='The X location of the selected voxel';
    case 'WindowSize'
        Tips ='The window width of the spin evolution plot';
    case 'ISOHighlight'
        Tips ='The flag for turning on and off isocenter mark';
    case 'Axes'
        Tips ='The flag for turning on and off axes label';
    case 'N_Gram'
        Units ='g';
        Tips ='The number to specify averaged N-gram SAR, set to 0 indicating unaveraged spatial SAR';
    case 'N_Second'
        Units ='s';
        Tips ='The nominal time window for SAR calculation';
end

if ~isempty(Units)
    TooltipString = [var '(' Units '): ' Tips];
else
    TooltipString = [var ': ' Tips];
end

end