%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)

%% befire the first run, we need to register some paths for arrayShow
% (this needs to be done only once)
disp('Adding arrShow folders to path');
basePath = pwd;
addpath(basePath);
addpath([basePath,filesep,'supportFunctions']);
addpath([basePath,filesep,'scripts']);
addpath([basePath,filesep,'cursorPosFcn']);
savepath();

%% Example: %%%%%%%%%%%%%%%%%%%%%

% create multi-echo, multi-frame, mutli-coil testdata
data1 = createMultiframeTestphan;

% do a standard Fourier reconstruction
img1 = asDataClass.mrIfft(data1);

% notice that the data is a 5-dimensional array with
% size(img1, 1) = 64 = read direction
% size(img1, 2) = 64 = phase direction
% size(img1, 3) = 16 = echoes
% size(img1, 4) = 30 = movie frames
% size(img1, 5) = 4  = coils
disp(size(img1));

% store some informations in a parameter struct
par.patient = 'Phantom';
par.study   = 'Test';
par.code    = 1.23;

%% display the images with arrayShow
as(img1, 'info', par);

%...try using the mouse wheel or the + and - keys to cycle through the different echoes.
% The windowing can be changed by pressing the 3rd mouse button.
% Doubleclick to reset windowing ...
%