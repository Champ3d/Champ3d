function design3d = f_postprocessing(design3d,varargin)
% F_POSTPROCESSING returns the solution fields.
% out_field = {'A','Phi','Flux','EMF','B','E','J','PVT','PST','pV','pS','coil','Energy','Voltage'};
%--------------------------------------------------------------------------
% design3d = F_POSTPROCESSING(design3d,'from','physics','out_field','J');
% design3d = F_POSTPROCESSING(design3d,'from','physics','out_field','B');
% design3d = F_POSTPROCESSING(design3d,'from','physics','out_field','P');
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------


design3d



fprintf('Time to perform post-processing : %.4f s \n',toc);