function design3d = f_postprocessing(design3d,varargin)
% F_POSTPROCESSING returns the solution fields.
% out_field = {'A','Phi','Flux','EMF','B','E','J','PVT','PST','pV','pS','coil','Energy','Voltage'};
%--------------------------------------------------------------------------
% design3d = F_POSTPROCESSING(design3d,'from','physics','out_field','J');
% design3d = F_POSTPROCESSING(design3d,'from','physics','out_field','B');
% design3d = F_POSTPROCESSING(design3d,'from','physics','out_field','P');
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------


design3d



fprintf('Time to perform post-processing : %.4f s \n',toc);