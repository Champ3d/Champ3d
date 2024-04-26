function design3d = f_postprocessing(design3d,varargin)
% F_POSTPROCESSING returns the solution fields.
% out_field = {'A','Phi','Flux','EMF','B','E','J','PVT','PST','pV','pS','coil','Energy','Voltage'};
%--------------------------------------------------------------------------
% design3d = F_POSTPROCESSING(design3d,'from','physics','out_field','J');
% design3d = F_POSTPROCESSING(design3d,'from','physics','out_field','B');
% design3d = F_POSTPROCESSING(design3d,'from','physics','out_field','P');
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------


design3d



fprintf('Time to perform post-processing : %.4f s \n',toc);